class PlantScopedController < ApplicationController
  before_action :load_plant
  helper_method :plant_navigation
  rescue_from ActiveRecord::RecordNotUnique, with: :conflicting_change
  rescue_from ActiveRecord::StatementInvalid, with: :database_conflict

  private

  def load_plant
    @plant = current_user.plants.find(params[:plant_id])
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
