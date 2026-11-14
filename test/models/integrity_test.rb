require "test_helper"

class IntegrityTest < ActiveSupport::TestCase
  setup { foundation }

  test "single operator is protected in database" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      Operator.insert_all!([ { name: "Second", singleton_key: 1, source_id: SecureRandom.uuid, created_at: Time.current, updated_at: Time.current } ])
    end
  end

  test "permissions cannot duplicate or reference missing users" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      PlantPermission.insert_all!([ { user_id: @clerk.id, plant_id: @plant.id, created_at: Time.current, updated_at: Time.current } ])
    end
  end

  test "foreign keys protect permission relationships" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      PlantPermission.insert_all!([ { user_id: -1, plant_id: @plant.id, created_at: Time.current, updated_at: Time.current } ])
    end
  end

  test "normalized login identity and password strength" do
    user = User.new(email_address: " CLERK@EXAMPLE.TEST ", password: "short")
    assert_not user.valid?
    assert_equal "clerk@example.test", user.email_address
    assert user.errors[:email_address].any?
    assert user.errors[:password].any?
  end

  test "UUID and audit are stable and protected" do
    assert_match(/\A[0-9a-f-]{36}\z/, @plant.id)
    event = AuditEvent.last
    assert_not event.update(action: "tampered")
    assert_not event.destroy
    assert_raises(ActiveRecord::DeleteRestrictionError) { @plant.destroy! }
  end

  test "non administrator service call cannot create" do
    assert_no_difference [ "Plant.count", "AuditEvent.count" ] do
      assert_raises(ActiveRecord::RecordNotFound) do
        Plants::Create.call(user: @clerk, attributes: { name: "No", street: "No", postal_code: "00000", city: "Testort" })
      end
    end
  end
end
