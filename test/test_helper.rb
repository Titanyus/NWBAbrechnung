ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  def foundation
    @operator = Operator.create!(name: "Testbetreiber")
    @admin = User.create!(email_address: "admin@example.test", password: "Synthetic-Password-2026", administrator: true)
    @clerk = User.create!(email_address: "clerk@example.test", password: "Synthetic-Password-2026")
    @plant = Plants::Create.call(user: @admin, attributes: { name: "Test Nord", street: "Musterweg 1", postal_code: "00000", city: "Testort" })
    @other = Plants::Create.call(user: @admin, attributes: { name: "Test Süd", street: "Musterweg 2", postal_code: "00000", city: "Testort" })
    @clerk.plant_permissions.create!(plant: @plant)
  end
end
