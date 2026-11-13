class PlantsController < ApplicationController
  before_action :require_administrator, only: [ :new, :create ]

  def index
    @plants = current_user.plants.order(:name)
  end

  def show
    @plant = current_user.plants.find(params[:id])
  end

  def new
    @plant = Plant.new
  end

  def create
    @plant = Plants::Create.call(user: current_user, attributes: params.require(:plant).permit(:name, :address, :technical_notes))
    redirect_to @plant, notice: "Anlage wurde angelegt.", status: :see_other
  rescue ActiveRecord::RecordInvalid => error
    @plant = error.record
    render :new, status: :unprocessable_entity
  end

  private

  def require_administrator
    head :forbidden unless current_user.administrator?
  end
end
