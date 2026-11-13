class User < ApplicationRecord
  has_secure_password
  normalizes :email_address, with: ->(email) { email.strip.downcase }
  has_many :sessions, dependent: :destroy
  has_many :plant_permissions, dependent: :restrict_with_exception
  has_many :plants, through: :plant_permissions
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 14 }, allow_nil: true
  after_update :revoke_sessions, if: :saved_change_to_password_digest?

  private

  def revoke_sessions
    sessions.destroy_all
  end
end
