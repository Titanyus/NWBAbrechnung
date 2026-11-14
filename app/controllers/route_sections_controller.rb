class RouteSectionsController < PlantScopedController
  include PlantWorkspace
  layout "contracts"
  before_action :load_record, only: [ :edit, :update ]

  def index
    prepare_plant_workspace
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
    if params[:within_plant] == "1"
      if turbo_frame_request? && request.format.turbo_stream?
        prepare_plant_workspace
        render turbo_stream: [
          turbo_stream.replace("plant_routes", partial: "plants/routes", locals: { message: "Trasse #{@route_section.name} gespeichert." }),
          turbo_stream.replace("plant_metrics", partial: "plants/metrics")
        ]
      else
        redirect_to plant_path(@plant, anchor: "plant_routes"), status: :see_other, notice: "Trasse gespeichert."
      end
    else
      redirect_to plant_route_sections_path(@plant), status: :see_other, notice: "Trasse gespeichert."
    end
  rescue ActiveRecord::RecordInvalid
    render(@route_section.persisted? ? :edit : :new, status: :unprocessable_entity, formats: [ :html ])
  end
end
