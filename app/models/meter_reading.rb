class MeterReading < ApplicationRecord
  KINDS = { "Jahresablesung" => "annual", "Zwischenablesung" => "interim", "Einbau" => "installation", "Ausbau" => "removal", "Korrektur / dokumentierter Sonderfall" => "correction" }.freeze
  attr_accessor :boundary_event

  belongs_to :heat_meter
  belongs_to :recorded_by, class_name: "User"
  belongs_to :supersedes, class_name: "MeterReading", optional: true
  delegate :plant, to: :heat_meter
  scope :effective, -> { where(superseded_at: nil) }
  validates :read_on, :recorded_at, presence: true
  validates :kind, inclusion: { in: KINDS.values }
  validates :value, numericality: { greater_than_or_equal_to: 0, less_than: 10**14 }
  validates :comment, length: { maximum: 4000 }
  validates :comment, presence: true, if: -> { kind == "correction" }
  validate :plausible_value
  before_update { throw :abort }
  before_destroy { throw :abort }

  private

  def plausible_value
    return unless read_on && heat_meter
    if read_on < heat_meter.installed_on || (heat_meter.removed_on && read_on > heat_meter.removed_on)
      errors.add(:read_on, "liegt außerhalb des Einbauzeitraums")
    end
    if kind == "installation" && read_on != heat_meter.installed_on
      errors.add(:read_on, "muss für einen Einbauwert dem Einbautag entsprechen")
    end
    if kind == "removal" && !boundary_event && heat_meter.removed_on != read_on
      errors.add(:base, "Ausbauwerte über den dokumentierten Zählerausbau oder Zählerwechsel erfassen.")
    end
    if supersedes && (supersedes.heat_meter_id != heat_meter_id || supersedes.read_on != read_on || kind != "correction")
      errors.add(:base, "Eine Korrektur muss denselben Zähler und Ablesetag betreffen.")
    end
    begin
      exact = BigDecimal(value_before_type_cast.to_s)
      errors.add(:value, "darf höchstens sechs Nachkommastellen haben") if exact != exact.round(6)
    rescue ArgumentError
      errors.add(:value, "ist kein gültiger Dezimalwert")
    end
    scope = heat_meter.meter_readings.effective.where.not(id: id)
    errors.add(:read_on, "hat bereits eine Ablesung; bitte diese nachvollziehbar korrigieren") if scope.where(read_on: read_on).exists?
    previous = scope.where("read_on < ?", read_on).order(read_on: :desc).first
    following = scope.where("read_on > ?", read_on).order(:read_on).first
    if value && ((previous && value < previous.value) || (following && following.value < value)) && kind != "correction"
      errors.add(:value, "ist rückläufig. Ein dokumentierter Sonderfall benötigt die Art Korrektur und eine Begründung.")
    end
  end
end
