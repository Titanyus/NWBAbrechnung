require "test_helper"

class DemoSeedTest < ActiveSupport::TestCase
  def seed(size)
    old_demo = ENV["NWB_LOAD_DEMO"]
    ENV["NWB_LOAD_DEMO"] = "1"
    old_size = ENV["DEMO_SIZE"]
    old_password = ENV["DEMO_PASSWORD"]
    ENV["DEMO_SIZE"] = size
    ENV["DEMO_PASSWORD"] = "Synthetic-Password-2026"
    load Rails.root.join("db/seeds.rb")
  ensure
    ENV["NWB_LOAD_DEMO"] = old_demo
    ENV["DEMO_SIZE"] = old_size
    ENV["DEMO_PASSWORD"] = old_password
  end

  test "automatic preparation never creates demo data" do
    previous = ENV.delete("NWB_LOAD_DEMO")
    assert_no_difference [ "Operator.count", "User.count", "Plant.count" ] do
      load Rails.root.join("db/seeds.rb")
    end
  ensure
    ENV["NWB_LOAD_DEMO"] = previous
  end

  test "small installation and repeatable seeds preserve identities and password" do
    seed("small")
    assert_equal 1, Operator.count
    assert_equal 3, Plant.count
    assert_equal 2, User.find_by!(email_address: "verwaltung@example.test").plants.count
    ids = Plant.order(:id).pluck(:id)
    admin = User.find_by!(email_address: "admin@example.test")
    admin.update!(password: "Changed-Synthetic-Password-2026")
    assert_no_difference [ "Plant.count", "PlantPermission.count", "AuditEvent.count", "User.count" ] do
      seed("small")
    end
    assert_equal ids, Plant.order(:id).pluck(:id)
    assert admin.reload.authenticate("Changed-Synthetic-Password-2026")
  end

  test "large installation has 50 plants and explicit partial authorization" do
    seed("large")
    assert_equal 1, Operator.count
    assert_equal 50, Plant.count
    assert_equal 50, User.find_by!(email_address: "admin@example.test").plants.count
    assert_equal 25, User.find_by!(email_address: "verwaltung@example.test").plants.count
    assert_equal 50, AuditEvent.count
  end
end
