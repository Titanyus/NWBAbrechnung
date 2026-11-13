class SupplyContractsController < PlantScopedController
  before_action :load_record, only: [ :show, :edit, :update ]

  def index
    @contracts = page(@plant.supply_contracts.includes(:connection, customer_membership: :customer).order(starts_on: :desc, id: :asc))
  end

  def show
    @history = AuditEvent.where(plant: @plant, subject_type: "SupplyContract", subject_id: @supply_contract.id).includes(:user).order(:occurred_at)
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
  end

  def contract_params
    params.require(:supply_contract).permit(:number, :starts_on, :ends_on, :status, :notes)
  end

  def save(attrs)
    connection = @supply_contract.persisted? ? @supply_contract.connection : attrs.fetch(:connection)
    connection.with_lock do
      MasterData::Change.save!(@supply_contract, attributes: attrs, user: current_user)
    end
    redirect_to plant_supply_contract_path(@plant, @supply_contract), status: :see_other, notice: "Vertrag gespeichert."
  rescue ActiveRecord::RecordInvalid
    render(@supply_contract.persisted? ? :edit : :new, status: :unprocessable_entity)
  end
end
