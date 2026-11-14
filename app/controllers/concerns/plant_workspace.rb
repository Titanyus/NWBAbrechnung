module PlantWorkspace
  extend ActiveSupport::Concern

  private

  def prepare_plant_workspace
    @plant_metrics = if @plant.persisted?
      { routes: @plant.route_sections.count, connections: @plant.connections.count, contracts: @plant.supply_contracts.count }
    else
      { routes: 0, connections: 0, contracts: 0 }
    end
    scope = @plant.route_sections
    @route_page = params[:route_page].to_i.clamp(1, 10000)
    @route_total = @plant_metrics[:routes]
    @routes = scope.order(:name, :id).limit(100).offset((@route_page - 1) * 100)
    ids = @routes.map(&:id)
    @route_connection_counts = @plant.connections.where(route_section_id: ids).group(:route_section_id).count
    @route_contract_counts = @plant.supply_contracts.joins(:connection).where(connections: { route_section_id: ids, plant_id: @plant.id }).group("connections.route_section_id").count
  end
end
