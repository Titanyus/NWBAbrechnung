class SupplyContract < ApplicationRecord
  STATUSES = { "Entwurf" => "draft", "Aktiv" => "active", "Beendet" => "ended", "Storniert" => "cancelled" }.freeze
  belongs_to :plant
  belongs_to :customer_membership
  belongs_to :connection
  delegate :customer, to: :customer_membership
  validates :number, presence: true, uniqueness: { scope: :plant_id }, length: { maximum: 100 }
  validates :starts_on, presence: true
  validates :status, inclusion: { in: STATUSES.values }
  validates :ends_on, presence: true, if: -> { status == "ended" }
  validates :notes, length: { maximum: 4000 }
  validate :consistent_assignment
  validate :date_range

  private

  def consistent_assignment
    errors.add(:base, "Kunde und Anschluss müssen zu dieser Anlage gehören.") if (customer_membership && customer_membership.plant_id != plant_id) || (connection && connection.plant_id != plant_id)
    if persisted? && (will_save_change_to_customer_membership_id? || will_save_change_to_connection_id? || will_save_change_to_plant_id?)
      errors.add(:base, "Bestehende Verträge nicht umhängen. Für einen Kundenwechsel einen neuen Vertrag anlegen.")
    end
  end

  def date_range
    return unless starts_on
    errors.add(:ends_on, "liegt vor dem Vertragsbeginn") if ends_on && ends_on < starts_on
    if %w[active ended].include?(status)
      scope = SupplyContract.where(connection_id: connection_id, status: %w[active ended]).where.not(id: id)
      scope = scope.where("ends_on IS NULL OR ends_on >= ?", starts_on)
      scope = scope.where("starts_on <= ?", ends_on) if ends_on
      errors.add(:base, "Der Lieferzeitraum überschneidet sich mit einem vorhandenen Vertrag.") if scope.exists?
    end
  end
end
