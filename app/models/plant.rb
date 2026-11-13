class Plant < ApplicationRecord
  belongs_to :operator
  has_many :plant_permissions, dependent: :restrict_with_exception
  validates :name, presence: true, length: { maximum: 150 }
  validates :address, presence: true, length: { maximum: 1000 }
  validates :technical_notes, length: { maximum: 4000 }
end
