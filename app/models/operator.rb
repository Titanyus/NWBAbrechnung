class Operator < ApplicationRecord
  has_many :plants, dependent: :restrict_with_exception
  has_many :customers, dependent: :restrict_with_exception
  validates :name, presence: true, length: { maximum: 150 }
  validates :singleton_key, inclusion: { in: [ 1 ] }, uniqueness: true
end
