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
      render :show
    else
      build_browser(selected: @supply_contract)
      render :index
    end
  end

  def new
    @supply_contract = @plant.supply_contracts.new
  end

  def create
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

  def load_record
    @supply_contract = @plant.supply_contracts.find(params[:id])
    raise ActiveRecord::RecordNotFound if @contract_context && @contract_context.id != @supply_contract.id
  end

  def contract_layout
    %w[index show].include?(action_name) ? "contracts" : "application"
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
    render(@supply_contract.persisted? ? :edit : :new, status: :unprocessable_entity)
  end
end
