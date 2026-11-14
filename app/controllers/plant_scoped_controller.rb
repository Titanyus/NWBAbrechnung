class PlantScopedController < ApplicationController
  before_action :load_plant
  before_action :load_contract_context
  around_action :keep_plant_active_for_write
  helper_method :plant_navigation, :contextual_path
  rescue_from ActiveRecord::RecordNotUnique, with: :conflicting_change
  rescue_from ActiveRecord::StatementInvalid, with: :database_conflict

  private

  def keep_plant_active_for_write
    if request.get? || request.head?
      yield
    else
      @plant.with_lock do
        raise ActiveRecord::RecordNotFound if @plant.deleted_at?
        yield
      end
    end
  end

  def load_plant
    @plant = current_user.plants.find(params[:plant_id])
  end

  def load_contract_context
    @contract_context = @plant.supply_contracts.find(params[:contract_id]) if params[:contract_id].present?
  end

  def verify_contract_resource!(customer: nil, connection: nil)
    return unless @contract_context
    if (customer && @contract_context.customer.id != customer.id) || (connection && @contract_context.connection_id != connection.id)
      raise ActiveRecord::RecordNotFound
    end
  end

  def contextual_path(fallback)
    @contract_context ? plant_supply_contract_path(@plant, @contract_context) : fallback
  end

  def prepare_contract_workspace(contract)
    @contract_context = contract
    @workspace_contract = contract.reload
    @workspace_connection = @workspace_contract.connection
    @workspace_customer = @workspace_contract.customer
    @workspace_membership = @workspace_contract.customer_membership
    @workspace_meter = @workspace_connection.heat_meters.where("installed_on <= ? AND (removed_on IS NULL OR removed_on > ?)", Date.current, Date.current).order(installed_on: :desc).first
    @workspace_reading = @workspace_meter&.meter_readings&.effective&.order(read_on: :desc)&.first
    @workspace_history = AuditEvent.where(plant: @plant, subject_type: "SupplyContract", subject_id: contract.id).includes(:user).order(:occurred_at)
  end

  def finish_edit(fallback, notice:)
    if @contract_context && turbo_frame_request? && request.format.turbo_stream?
      prepare_contract_workspace(@contract_context)
      render turbo_stream: turbo_stream.replace("contract_workspace", partial: "supply_contracts/workspace", locals: { message: notice })
    else
      redirect_to contextual_path(fallback), status: :see_other, notice: notice
    end
  end

  def page(scope)
    @page = [ params[:page].to_i, 1 ].max.clamp(1, 10000)
    scope.limit(100).offset((@page - 1) * 100)
  end

  def plant_navigation
    current_user.plants.order(:name)
  end

  def meter_scope
    HeatMeter.joins(:connection).where(connections: { plant_id: @plant.id })
  end

  def conflicting_change
    redirect_to plant_path(@plant), alert: "Die Änderung kollidiert mit einem vorhandenen Datensatz. Bitte die Angaben erneut prüfen.", status: :see_other
  end

  def database_conflict(error)
    if [ PG::ExclusionViolation, PG::CheckViolation, PG::ForeignKeyViolation ].any? { |type| error.cause.is_a?(type) }
      conflicting_change
    else
      raise error
    end
  end
end
