class Connection < ApplicationRecord
  include StructuredAddress
  STATUSES = { "Geplant" => "planned", "Aktiv" => "active", "Inaktiv" => "inactive" }.freeze
  belongs_to :plant
  belongs_to :route_section, optional: true
  has_many :heat_meters, dependent: :restrict_with_exception
  has_many :supply_contracts, dependent: :restrict_with_exception
  validates :number, presence: true, uniqueness: { scope: :plant_id }, length: { maximum: 100 }
  validates :notes, length: { maximum: 4000 }
  validates :technical_status, inclusion: { in: STATUSES.values }
  validate { errors.add(:route_section, "gehört zu einer anderen Anlage") if route_section && route_section.plant_id != plant_id }
end
