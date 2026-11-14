class PlantsController < ApplicationController
  include PlantWorkspace
  before_action :require_administrator, only: [ :new, :create, :edit, :update, :delete_confirmation, :destroy ]
  before_action :load_plant, only: [ :show, :edit, :update, :delete_confirmation, :destroy ]
  layout "contracts"

  def index
    scope = current_user.plants
    if params[:q].present?
      scope = scope.where("name ILIKE :q OR concat_ws(' ', street, postal_code, city) ILIKE :q", q: "%#{Plant.sanitize_sql_like(params[:q].to_s.first(200))}%")
    end
    @sort = %w[name address].include?(params[:sort]) ? params[:sort] : "name"
    @page = params[:page].to_i.clamp(1, 10000)
    @total = scope.count
    @plants = scope.order(*(@sort == "address" ? %i[city postal_code street] : [ :name ]), :id).limit(100).offset((@page - 1) * 100)
    ids = @plants.map(&:id)
    @connection_counts = Connection.where(plant_id: ids).group(:plant_id).count
    @route_counts = RouteSection.where(plant_id: ids).group(:plant_id).count
    @contract_counts = SupplyContract.where(plant_id: ids).group(:plant_id).count
  end

  def show
    prepare_plant_workspace
  end

  def new
    @plant = Plant.new
    prepare_plant_workspace
  end

  def create
    @plant = Plants::Create.call(user: current_user, attributes: plant_params)
    session[:selected_plant_id] = @plant.id
    redirect_to plants_path, notice: "Anlage wurde angelegt.", status: :see_other
  rescue ActiveRecord::RecordInvalid => error
    @plant = error.record
    prepare_plant_workspace
    render :new, status: :unprocessable_entity, formats: [ :html ]
  end

  def edit
    prepare_plant_workspace
  end

  def update
    Plant.transaction do
      @plant.lock!
      raise ActiveRecord::RecordNotFound if @plant.deleted_at?
      @plant.update!(plant_params)
      MasterData::Change.audit!(@plant, user: current_user, plant: @plant)
    end
    redirect_to plants_path, notice: "Anlage wurde gespeichert.", status: :see_other
  rescue ActiveRecord::RecordInvalid
    prepare_plant_workspace
    render :edit, status: :unprocessable_entity, formats: [ :html ]
  end

  def delete_confirmation
    @deletion_blocked = Plants::Remove.blocked?(@plant)
    @deletion_confirmation = Plants::Remove.confirmation_for(plant: @plant, user: current_user)
  end

  def destroy
    Plants::Remove.call(plant: @plant, user: current_user, confirmation: params[:confirmation])
    session.delete(:selected_plant_id) if session[:selected_plant_id] == @plant.id
    redirect_to plants_path, status: :see_other, notice: "Anlage wurde gelöscht."
  rescue Plants::Remove::ConfirmationRequired
    redirect_to delete_confirmation_plant_path(@plant), status: :see_other, alert: "Bitte bestätigen Sie das Löschen erneut."
  rescue Plants::Remove::NotEmpty
    redirect_to edit_plant_path(@plant), status: :see_other, alert: "Anlage kann nicht gelöscht werden: Es sind noch Trassen, Kunden, Hausanschlüsse oder Verträge zugeordnet."
  end

  private

  def load_plant
    @plant = current_user.plants.find(params[:id])
  end

  def plant_params
    params.require(:plant).permit(:name, :street, :postal_code, :city, :technical_notes)
  end

  def require_administrator
    head :forbidden unless current_user.administrator?
  end
end
