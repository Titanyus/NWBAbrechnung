class PlantPermission < ApplicationRecord
  belongs_to :user
  belongs_to :plant
  validates :plant_id, uniqueness: { scope: :user_id }
end
