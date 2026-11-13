class HeatMetersController < PlantScopedController
  before_action :load_record, only: [ :show, :edit, :update, :replacement, :exchange, :retire ]

  def index
    @meters = page(meter_scope.includes(:connection).order(installed_on: :desc, id: :asc))
  end

  def show
    @readings = @heat_meter.meter_readings.includes(:recorded_by).order(read_on: :desc, recorded_at: :desc)
    @history = AuditEvent.where(plant: @plant, subject_type: "HeatMeter", subject_id: @heat_meter.id).includes(:user).order(:occurred_at)
  end

  def new
    @heat_meter = HeatMeter.new(connection_id: @plant.connections.find(params[:connection_id]).id) if params[:connection_id].present?
    @heat_meter ||= HeatMeter.new
  end

  def create
    connection = @plant.connections.find(params.require(:heat_meter)[:connection_id])
    @heat_meter = MasterData::Meters.install!(connection: connection, attributes: meter_params, initial_value: params[:initial_value], user: current_user)
    redirect_to plant_heat_meter_path(@plant, @heat_meter), status: :see_other, notice: "Zähler mit Anfangswert eingebaut."
  rescue ActiveRecord::RecordInvalid => error
    @heat_meter = error.record.is_a?(HeatMeter) ? error.record : HeatMeter.new(meter_params.merge(connection: connection))
    @heat_meter.errors.add(:base, error.record.errors.full_messages.join("; ")) unless error.record == @heat_meter
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    MasterData::Change.save!(@heat_meter, attributes: params.require(:heat_meter).permit(:serial_number, :notes), user: current_user)
    redirect_to plant_heat_meter_path(@plant, @heat_meter), status: :see_other, notice: "Zähler gespeichert."
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  def replacement
  end

  def exchange
    date = Date.iso8601(params.require(:exchange_on))
    replacement = MasterData::Meters.exchange!(meter: @heat_meter, on: date, closing_value: params[:closing_value], attributes: params.require(:heat_meter).permit(:serial_number, :unit, :notes).to_h, initial_value: params[:initial_value], user: current_user)
    redirect_to plant_heat_meter_path(@plant, replacement), status: :see_other, notice: "Zählerwechsel mit Schluss- und Anfangswert gespeichert."
  rescue ActiveRecord::RecordInvalid => error
    @heat_meter.errors.add(:base, error.record.errors.full_messages.join("; "))
    render :replacement, status: :unprocessable_entity
  rescue ArgumentError
    @heat_meter.errors.add(:base, "Bitte einen gültigen Wechseltag und Dezimalwerte eingeben.")
    render :replacement, status: :unprocessable_entity
  end

  def retire
    MasterData::Meters.retire!(meter: @heat_meter, removed_on: Date.iso8601(params.require(:removed_on)), closing_value: params[:closing_value], user: current_user)
    redirect_to plant_heat_meter_path(@plant, @heat_meter), status: :see_other, notice: "Zähler mit Schlusswert ausgebaut."
  rescue ActiveRecord::RecordInvalid, ArgumentError
    redirect_to plant_heat_meter_path(@plant, @heat_meter), status: :see_other, alert: "Ausbau nicht gespeichert: Datum, Schlusswert und Einbauzeitraum prüfen."
  end

  private

  def load_record
    @heat_meter = meter_scope.find(params[:id])
  end

  def meter_params
    params.require(:heat_meter).permit(:serial_number, :installed_on, :unit, :notes).to_h
  end
end
