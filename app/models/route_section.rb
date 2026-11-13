class RouteSection < ApplicationRecord
  belongs_to :plant
  has_many :connections, dependent: :restrict_with_exception
  validates :name, presence: true, length: { maximum: 150 }
  validates :code, length: { maximum: 100 }
  validates :description, length: { maximum: 4000 }
end
