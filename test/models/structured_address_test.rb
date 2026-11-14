require "test_helper"
require_relative "../support/master_data_setup"

class StructuredAddressTest < ActiveSupport::TestCase
  include MasterDataSetup
  setup { master_data }

  test "all three models require separate fields and format address from one source" do
    [ @plant, @customer, @connection ].each do |record|
      assert_not_includes record.class.column_names, "address"
      record.update!(street: " Beispielweg 7 ", postal_code: " 01234 ", city: " Beispielort ")
      assert_equal "01234", record.reload.postal_code
      assert_equal "Beispielweg 7\n01234 Beispielort", record.address
      record.city = ""
      assert_not record.valid?
      assert record.errors[:city].any?
    end
  end

  test "database rejects incomplete structured addresses even without validations" do
    [ @plant, @customer, @connection ].each do |record|
      assert_raises(ActiveRecord::StatementInvalid) do
        record.class.transaction(requires_new: true) { record.update_columns(postal_code: " ") }
      end
      assert_equal "00000", record.reload.postal_code
    end
  end

  test "multiline address components are rejected and no numeric postal conversion occurs" do
    @customer.street = "Straße\nZusatz"
    assert_not @customer.valid?
    @customer.street = "Straße 1"
    @customer.postal_code = "00123"
    assert @customer.valid?
    @customer.save!
    assert_equal "00123", @customer.reload.postal_code
  end
end
