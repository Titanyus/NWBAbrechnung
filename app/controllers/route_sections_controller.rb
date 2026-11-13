class RouteSectionsController < PlantScopedController
  before_action :load_record, only: [ :edit, :update ]

  def index
    @route_sections = page(@plant.route_sections.order(:name, :id))
  end

  def new
    @route_section = @plant.route_sections.new
  end

  def create
    @route_section = @plant.route_sections.new
    save
  end

  def edit
  end

  def update
    save
  end

  private

  def load_record
    @route_section = @plant.route_sections.find(params[:id])
  end

  def save
    MasterData::Change.save!(@route_section, attributes: params.require(:route_section).permit(:name, :code, :description), user: current_user)
    redirect_to plant_route_sections_path(@plant), status: :see_other, notice: "Trasse gespeichert."
  rescue ActiveRecord::RecordInvalid
    render(@route_section.persisted? ? :edit : :new, status: :unprocessable_entity)
  end
end
