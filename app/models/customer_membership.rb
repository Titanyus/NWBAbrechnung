class CustomerMembership < ApplicationRecord
  PAYMENT_METHODS = { "Überweisung" => "bank_transfer", "Lastschrift" => "direct_debit", "Barzahlung" => "cash", "Sonstige" => "other" }.freeze
  belongs_to :customer
  belongs_to :plant
  has_many :supply_contracts, dependent: :restrict_with_exception
  normalizes :customer_number, with: ->(number) { number.to_s.strip.presence }
  validates :customer_number, uniqueness: { scope: :plant_id }, allow_nil: true, length: { maximum: 100 }
  validates :customer_id, uniqueness: { scope: :plant_id }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS.values }
  validate { errors.add(:customer, "gehört zu einem anderen Betreiber") if customer && plant && customer.operator_id != plant.operator_id }
end
