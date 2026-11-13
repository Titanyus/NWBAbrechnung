class ConnectionsController < PlantScopedController
  before_action :load_record, only: [ :show, :edit, :update ]

  def index
    scope = @plant.connections.includes(:route_section).order(:number, :id)
    scope = scope.where("number ILIKE :q OR address ILIKE :q", q: "%#{Connection.sanitize_sql_like(params[:q].to_s.first(200))}%") if params[:q].present?
    @connections = page(scope)
  end

  def show
    @contracts = @connection.supply_contracts.includes(customer_membership: :customer).order(starts_on: :desc)
    @meters = @connection.heat_meters.order(installed_on: :desc)
  end

  def new
    @connection = @plant.connections.new
  end

  def create
    @connection = @plant.connections.new
    save
  end

  def edit
  end

  def update
    save
  end

  private

  def load_record
    @connection = @plant.connections.find(params[:id])
    verify_contract_resource!(connection: @connection)
  end

  def save
    attrs = params.require(:connection).permit(:number, :address, :commissioned_on, :technical_status, :notes)
    route_id = params.require(:connection)[:route_section_id]
    attrs[:route_section] = route_id.present? ? @plant.route_sections.find(route_id) : nil
    MasterData::Change.save!(@connection, attributes: attrs, user: current_user)
    finish_edit(plant_connection_path(@plant, @connection), notice: "Anschluss gespeichert.")
  rescue ActiveRecord::RecordInvalid
    render(@connection.persisted? ? :edit : :new, status: :unprocessable_entity)
  end
end
