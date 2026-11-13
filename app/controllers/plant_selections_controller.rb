class PlantSelectionsController < ApplicationController
  def update
    plant = current_user.plants.find(params.require(:selected_plant_id))
    session[:selected_plant_id] = plant.id
    redirect_to(params[:area] == "contracts" ? plant_supply_contracts_path(plant) : plant_path(plant), status: :see_other)
  end
end
