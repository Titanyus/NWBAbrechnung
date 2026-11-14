class SupplyContractsController < PlantScopedController
  before_action :load_record, only: [ :show, :edit, :update ]
  layout :contract_layout
  rescue_from ContractBrowser::InvalidCursor, with: :invalid_browser_cursor

  def index
    build_browser
    if params[:cursor].present?
      render partial: "browser_page", layout: false
    else
      render :index
    end
  end

  def show
    prepare_contract_workspace(@supply_contract)
    @detail_tab = params[:tab] == "history" ? "history" : "overview"
    if turbo_frame_request?
      prepare_created_list_update if params[:created] == "1"
      render :show
    else
      build_browser(selected: @supply_contract)
      render :index
    end
  end

  def new
    prepare_draft
    render_draft
  end

  def draft_customers
    load_draft_customers
    render partial: "draft_customers"
  end

  def draft_connections
    load_draft_connections
    render partial: "draft_connections"
  end

  def draft_meter
    @draft_connection = @plant.connections.find(params[:connection_id]) if params[:connection_id].present?
    @allow_meter = params[:new_connection] == "1" || @draft_connection.present?
    @heat_meter = HeatMeter.new
    load_draft_meter
    render partial: "draft_meter"
  end

  def create
    if params[:contract_draft].present?
      prepare_draft
      if @draft.save
        browser = ContractBrowser.new(plant: @plant, user: current_user, parameters: params)
        redirect_to plant_supply_contract_path(@plant, @draft.contract, **browser.filters, created: "1"), status: :see_other
      else
        render_draft(status: :unprocessable_entity)
      end
      return
    end
    @supply_contract = @plant.supply_contracts.new
    attrs = contract_params
    attrs[:customer_membership] = @plant.customer_memberships.find(params.require(:supply_contract)[:customer_membership_id])
    attrs[:connection] = @plant.connections.find(params.require(:supply_contract)[:connection_id])
    save(attrs)
  end

  def edit
  end

  def update
    submitted = params.require(:supply_contract)
    if (submitted[:customer_membership_id].present? && submitted[:customer_membership_id] != @supply_contract.customer_membership_id) || (submitted[:connection_id].present? && submitted[:connection_id] != @supply_contract.connection_id)
      head :unprocessable_entity
      return
    end
    save(contract_params)
  end

  private

  def prepare_draft
    selection = params.fetch(:contract_draft, ActionController::Parameters.new).permit(:customer_mode, :connection_mode, :meter_mode, :customer_membership_id, :connection_id).to_h.symbolize_keys
    @draft = Contracts::Draft.new(plant: @plant, user: current_user, selection: selection,
      customer: params.fetch(:customer, ActionController::Parameters.new).permit(:first_name, :last_name, :company_name, :street, :postal_code, :city, :phone, :email, :notes).to_h.symbolize_keys,
      membership: params.fetch(:customer_membership, ActionController::Parameters.new).permit(:customer_number, :payment_method, :direct_debit_agreement, :active).to_h.symbolize_keys,
      connection: params.fetch(:connection, ActionController::Parameters.new).permit(:number, :street, :postal_code, :city, :route_section_id, :commissioned_on, :technical_status, :notes).to_h.symbolize_keys,
      meter: params.fetch(:heat_meter, ActionController::Parameters.new).permit(:serial_number, :installed_on, :unit, :notes).to_h.symbolize_keys,
      contract: params.fetch(:supply_contract, ActionController::Parameters.new).permit(:number, :starts_on, :ends_on, :status, :notes).to_h.symbolize_keys,
      initial_value: params[:initial_value])
    @customer, @membership, @connection, @heat_meter, @supply_contract = @draft.new_customer, @draft.new_membership, @draft.new_connection, @draft.new_meter, @draft.contract
    @draft_connection = @draft.selected_connection
    @allow_meter = @draft.connection_mode == "new" || @draft_connection.present?
    load_draft_customers(selected: @draft.selected_membership)
    load_draft_connections(selected: @draft.selected_connection)
    load_draft_meter
    @return_contract = @plant.supply_contracts.find_by(id: params[:selected_contract_id]) if params[:selected_contract_id].present?
    @browser = ContractBrowser.new(plant: @plant, user: current_user, parameters: params)
  end

  def render_draft(status: :ok)
    if turbo_frame_request?
      render :new, status: status, formats: [ :html ]
    else
      build_browser
      @creating_contract = true
      render :index, status: status, formats: [ :html ], layout: "contracts"
    end
  end

  def load_draft_customers(selected: nil)
    scope = @plant.customer_memberships.includes(:customer).joins(:customer)
    if params[:q].present? && action_name == "draft_customers"
      term = "%#{Customer.sanitize_sql_like(params[:q].to_s.first(200))}%"
      scope = scope.where("concat_ws(' ', customers.company_name, customers.first_name, customers.last_name, customers.street, customers.postal_code, customers.city, customer_memberships.customer_number) ILIKE ?", term)
    end
    @draft_customers = scope.order("customers.company_name", "customers.last_name", "customer_memberships.id").limit(20).to_a
    @draft_customer_result_count = @draft_customers.length
    selected ||= @plant.customer_memberships.includes(:customer).find(params[:selected_id]) if params[:selected_id].present?
    @draft_customers << selected if selected && @draft_customers.none? { |record| record.id == selected.id }
    @selected_customer_id = selected&.id
  end

  def load_draft_connections(selected: nil)
    scope = @plant.connections.left_joins(:route_section).includes(:route_section)
    if params[:q].present? && action_name == "draft_connections"
      term = "%#{Connection.sanitize_sql_like(params[:q].to_s.first(200))}%"
      scope = scope.where("concat_ws(' ', connections.number, connections.street, connections.postal_code, connections.city, route_sections.name, route_sections.code) ILIKE ?", term)
    end
    @draft_connections = scope.order("connections.number", "connections.id").limit(20).to_a
    @draft_connection_result_count = @draft_connections.length
    selected ||= @plant.connections.find(params[:selected_id]) if params[:selected_id].present?
    @draft_connections << selected if selected && @draft_connections.none? { |record| record.id == selected.id }
    @selected_connection_id = selected&.id
  end

  def load_draft_meter
    @active_draft_meter = @draft_connection&.heat_meters&.where("installed_on <= ? AND (removed_on IS NULL OR removed_on > ?)", Date.current, Date.current)&.order(installed_on: :desc)&.first
    @active_draft_reading = @active_draft_meter&.meter_readings&.effective&.order(read_on: :desc)&.first
  end

  def prepare_created_list_update
    @browser = ContractBrowser.new(plant: @plant, user: current_user, parameters: params)
    @contract_count = @browser.count
    batch = @browser.batch
    index = batch.index { |record| record.id == @supply_contract.id }
    @created_in_first_batch = !index.nil?
    @created_previous_contract = batch[index - 1] if index && index.positive?
  end

  def load_record
    @supply_contract = @plant.supply_contracts.find(params[:id])
    raise ActiveRecord::RecordNotFound if @contract_context && @contract_context.id != @supply_contract.id
  end

  def contract_layout
    %w[index show new].include?(action_name) ? "contracts" : "application"
  end

  def build_browser(selected: nil)
    @browser = ContractBrowser.new(plant: @plant, user: current_user, parameters: params)
    @contracts = @browser.batch(cursor: params[:cursor])
    return if params[:cursor].present?
    @contract_count = @browser.count
    selected ||= @browser.scope.find_by(id: params[:selected_contract_id]) if params[:selected_contract_id].present?
    selected ||= @contracts.first
    prepare_contract_workspace(selected) if selected
    @detail_tab = params[:tab] == "history" ? "history" : "overview"
  end

  def invalid_browser_cursor
    frame = request.headers["Turbo-Frame"].to_s
    frame = "contracts_page_error" unless frame.match?(/\Acontracts_page_\d+\z/)
    render partial: "browser_page_error", locals: { frame_id: frame }, status: :bad_request, layout: false
  end

  def contract_params
    params.require(:supply_contract).permit(:number, :starts_on, :ends_on, :status, :notes)
  end

  def save(attrs)
    connection = @supply_contract.persisted? ? @supply_contract.connection : attrs.fetch(:connection)
    connection.with_lock do
      MasterData::Change.save!(@supply_contract, attributes: attrs, user: current_user)
    end
    finish_edit(plant_supply_contract_path(@plant, @supply_contract), notice: "Vertrag gespeichert.")
  rescue ActiveRecord::RecordInvalid
    if @supply_contract.persisted?
      render :edit, status: :unprocessable_entity, formats: [ :html ]
    else
      submitted = params.require(:supply_contract)
      params[:contract_draft] = { customer_mode: "existing", connection_mode: "existing", customer_membership_id: submitted[:customer_membership_id], connection_id: submitted[:connection_id] }
      prepare_draft
      @draft.valid?
      render_draft(status: :unprocessable_entity)
    end
  end
end
