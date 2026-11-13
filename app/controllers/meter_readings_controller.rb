class MeterReadingsController < PlantScopedController
  before_action :load_meter

  def new
    @supersedes = @meter.meter_readings.effective.find(params[:supersedes_id]) if params[:supersedes_id].present?
    @reading = @meter.meter_readings.new(read_on: @supersedes&.read_on || Date.current, kind: @supersedes ? "correction" : "interim")
  end

  def create
    attrs = params.require(:meter_reading).permit(:read_on, :value, :kind, :comment)
    @supersedes = @meter.meter_readings.effective.find(params.require(:meter_reading)[:supersedes_id]) if params.require(:meter_reading)[:supersedes_id].present?
    attrs[:kind] = "correction" if @supersedes
    MasterData::Readings.record!(meter: @meter, attributes: attrs.to_h, user: current_user, supersedes: @supersedes)
    finish_edit(plant_heat_meter_path(@plant, @meter), notice: "Ablesung nachvollziehbar gespeichert.")
  rescue ActiveRecord::RecordInvalid => error
    @reading = error.record
    render :new, status: :unprocessable_entity
  end

  private

  def load_meter
    @meter = meter_scope.find(params[:heat_meter_id])
    verify_contract_resource!(connection: @meter.connection)
  end
end
