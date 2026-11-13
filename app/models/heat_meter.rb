class HeatMeter < ApplicationRecord
  belongs_to :connection
  has_many :meter_readings, dependent: :restrict_with_exception
  delegate :plant, to: :connection
  validates :serial_number, presence: true, length: { maximum: 100 }
  validates :installed_on, presence: true
  validates :unit, inclusion: { in: %w[kWh MWh] }
  validates :notes, length: { maximum: 4000 }
  validate :installation_range

  private

  def installation_range
    return unless installed_on
    errors.add(:removed_on, "muss nach dem Einbautag liegen") if removed_on && removed_on <= installed_on
    if persisted? && (will_save_change_to_connection_id? || will_save_change_to_installed_on? || will_save_change_to_unit?)
      errors.add(:base, "Anschluss, Einbautag und Einheit bleiben historisch erhalten.")
    end
    if persisted? && will_save_change_to_removed_on? && (removed_on.nil? || !meter_readings.effective.exists?(read_on: removed_on))
      errors.add(:removed_on, "benötigt einen dokumentierten Schlusswert")
    end
    if removed_on && meter_readings.effective.where("read_on > ?", removed_on).exists?
      errors.add(:removed_on, "liegt vor einer vorhandenen Ablesung")
    end
    scope = HeatMeter.where(connection_id: connection_id).where.not(id: id).where("removed_on IS NULL OR removed_on > ?", installed_on)
    scope = scope.where("installed_on < ?", removed_on) if removed_on
    errors.add(:base, "An diesem Anschluss ist bereits ein Hauptwärmezähler im gewählten Zeitraum eingebaut.") if scope.exists?
  end
end
