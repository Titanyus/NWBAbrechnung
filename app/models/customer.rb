class Customer < ApplicationRecord
  include StructuredAddress
  belongs_to :operator
  has_many :customer_memberships, dependent: :restrict_with_exception
  has_many :plants, through: :customer_memberships
  validates :first_name, :last_name, :company_name, :phone, :email, length: { maximum: 200 }
  validates :notes, length: { maximum: 4000 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate do
    errors.add(:base, "Firmenname oder Vor- und Nachname müssen ausgefüllt werden.") unless company_name.present? || (first_name.present? && last_name.present?)
  end

  def display_name
    company_name.presence || [ first_name, last_name ].compact.join(" ")
  end
end
