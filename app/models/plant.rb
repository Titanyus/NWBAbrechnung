class Plant < ApplicationRecord
  include StructuredAddress
  belongs_to :operator
  has_many :plant_permissions, dependent: :restrict_with_exception
  has_many :customer_memberships, dependent: :restrict_with_exception
  has_many :customers, through: :customer_memberships
  has_many :route_sections, dependent: :restrict_with_exception
  has_many :connections, dependent: :restrict_with_exception
  has_many :supply_contracts, dependent: :restrict_with_exception
  validates :name, presence: true, length: { maximum: 150 }
  validates :technical_notes, length: { maximum: 4000 }
end
