require "test_helper"
require_relative "../support/master_data_setup"

class MasterDataTest < ActiveSupport::TestCase
  include MasterDataSetup
  setup { master_data }

  test "one customer has many connections and memberships without duplicated contact data" do
    second = @plant.connections.create!(number: "A-2", address: "Testweg 2")
    other_membership = @other.customer_memberships.create!(customer: @customer, customer_number: "101")
    contract.save!
    contract(connection: second).save!
    @other.supply_contracts.create!(connection: @foreign_connection, customer_membership: other_membership, number: "O-1", starts_on: "2026-01-01", status: "active")
    assert_equal 2, @customer.plants.count
    assert_equal 3, SupplyContract.joins(:customer_membership).where(customer_memberships: { customer_id: @customer.id }).count
    assert_equal @membership.customer_number, @foreign_membership.customer_number
    assert_no_difference "Customer.count" do
      @customer.update!(first_name: "Neuer Testname")
    end
    assert_equal @customer.id, other_membership.reload.customer.id
  end

  test "customer identities optional numbers and companies validate" do
    assert_not @operator.customers.new(address: "x").valid?
    assert @operator.customers.new(company_name: "Test GmbH", address: "x").valid?
    @membership.update!(customer_number: "  ")
    assert_nil @membership.reload.customer_number
    assert_not @plant.customer_memberships.new(customer: @foreign_customer, customer_number: @membership.update!(customer_number: "100") && "100").valid?
  end

  test "contracts retain historical customers and use inclusive nonoverlapping dates" do
    old = contract(ends_on: "2026-06-30", status: "ended")
    MasterData::Change.save!(old, attributes: {}, user: @admin)
    next_contract = contract(starts_on: "2026-07-01")
    next_contract.save!
    assert_not contract(starts_on: "2026-06-30").valid?
    assert contract(starts_on: "2026-03-01", status: "draft").valid?
    assert_not old.update(customer_membership: @foreign_membership)
    assert_not old.update(connection: @foreign_connection)
    old.reload
    assert_equal @membership.id, old.customer_membership_id
    assert_equal @customer.id, old.customer.id
  end

  test "database rejects contract overlap even if validation is bypassed" do
    contract.save!
    candidate = contract(number: "DB-2")
    assert_raises ActiveRecord::StatementInvalid do
      SupplyContract.transaction(requires_new: true) { candidate.save!(validate: false) }
    end
  end

  test "composite foreign keys reject associations across plants" do
    invalid = contract(membership: @foreign_membership)
    assert_not invalid.valid?
    assert_raises ActiveRecord::InvalidForeignKey do
      SupplyContract.transaction(requires_new: true) { invalid.save!(validate: false) }
    end
    foreign_route = @other.route_sections.create!(name: "Fremd")
    @connection.route_section = foreign_route
    assert_not @connection.valid?
    assert_raises ActiveRecord::InvalidForeignKey do
      Connection.transaction(requires_new: true) { @connection.save!(validate: false) }
    end
  end

  test "meter replacement saves both boundary readings and preserves old values" do
    old = install
    id = old.id
    reading = old.meter_readings.first
    replacement = MasterData::Meters.exchange!(meter: old, on: Date.new(2026, 6, 1), closing_value: "110.625", attributes: { serial_number: "SYN-NEW", unit: "kWh" }, initial_value: "0.001", user: @admin)
    assert_equal Date.new(2026, 6, 1), old.reload.removed_on
    assert_equal Date.new(2026, 6, 1), replacement.installed_on
    assert_equal id, reading.reload.heat_meter_id
    assert_equal BigDecimal("10.125"), reading.value
    assert_equal BigDecimal("110.625"), old.meter_readings.effective.order(:read_on).last.value
    assert_equal BigDecimal("0.001"), replacement.meter_readings.first.value
    assert_not replacement.update(unit: "MWh")
    assert_equal 2, @connection.heat_meters.count
  end

  test "failed replacement without new opening reading rolls back removal and audit" do
    old = install
    assert_no_difference [ "HeatMeter.count", "MeterReading.count", "AuditEvent.count" ] do
      assert_raises ActiveRecord::RecordInvalid do
        MasterData::Meters.exchange!(meter: old, on: Date.new(2026, 6, 1), closing_value: "99", attributes: { serial_number: "NEW", unit: "kWh" }, initial_value: nil, user: @admin)
      end
    end
    assert_nil old.reload.removed_on
  end

  test "database rejects concurrently active main meters even without validations" do
    meter = install
    candidate = @connection.heat_meters.new(serial_number: "DUP", installed_on: meter.installed_on, unit: "kWh")
    assert_not candidate.valid?
    assert_raises ActiveRecord::StatementInvalid do
      HeatMeter.transaction(requires_new: true) { candidate.save!(validate: false) }
    end
  end

  test "annual and arbitrarily many interim readings retain decimal precision" do
    meter = install
    %w[02 03 04 05 06 07 08].each_with_index do |month, index|
      MasterData::Readings.record!(meter: meter, attributes: { read_on: "2026-#{month}-01", value: "#{20 + index}.123456", kind: "interim" }, user: @clerk)
    end
    annual = MasterData::Readings.record!(meter: meter, attributes: { read_on: "2026-12-31", value: "40.123456", kind: "annual" }, user: @clerk)
    assert_equal BigDecimal("40.123456"), annual.reload.value
    assert_equal 9, meter.meter_readings.count
    assert_equal @clerk, annual.recorded_by
    assert annual.recorded_at
  end

  test "negative duplicate out of lifetime and rounded readings are rejected" do
    meter = install
    [ { read_on: "2026-02-01", value: "-1" }, { read_on: "2026-01-01", value: "11" }, { read_on: "2025-12-31", value: "11" }, { read_on: "2026-02-01", value: "11.1234567" } ].each do |attrs|
      assert_raises ActiveRecord::RecordInvalid do
        MasterData::Readings.record!(meter: meter, attributes: attrs.merge(kind: "interim"), user: @clerk)
      end
    end
    %w[NaN Infinity -Infinity not-a-number].each do |value|
      assert_raises ActiveRecord::RecordInvalid do
        MasterData::Readings.record!(meter: meter, attributes: { read_on: "2026-02-01", value: value, kind: "interim" }, user: @clerk)
      end
    end
    assert_equal 1, meter.meter_readings.count
  end

  test "backdated readings are checked against previous and following values" do
    meter = install
    MasterData::Readings.record!(meter: meter, attributes: { read_on: "2026-06-01", value: "30", kind: "interim" }, user: @admin)
    [ "5", "40" ].each do |value|
      assert_raises ActiveRecord::RecordInvalid do
        MasterData::Readings.record!(meter: meter, attributes: { read_on: "2026-03-01", value: value, kind: "interim" }, user: @admin)
      end
    end
    special = MasterData::Readings.record!(meter: meter, attributes: { read_on: "2026-03-01", value: "5", kind: "correction", comment: "Dokumentierter synthetischer Gerätefehler; keine Verbrauchsberechnung" }, user: @admin)
    assert_equal BigDecimal("5"), special.value
  end

  test "corrections preserve originals and require a reason and the original day" do
    meter = install
    old = meter.meter_readings.first
    attrs = { read_on: old.read_on, value: "11", kind: "correction", comment: "Synthetischer Übertragungsfehler" }
    assert_raises ActiveRecord::RecordInvalid do
      MasterData::Readings.record!(meter: meter, attributes: attrs.merge(comment: ""), user: @clerk, supersedes: old)
    end
    assert_nil old.reload.superseded_at
    assert_raises ActiveRecord::RecordInvalid do
      MasterData::Readings.record!(meter: meter, attributes: attrs.merge(read_on: old.read_on + 1), user: @clerk, supersedes: old)
    end
    corrected = MasterData::Readings.record!(meter: meter, attributes: attrs, user: @clerk, supersedes: old.reload)
    assert_equal old.id, corrected.supersedes_id
    assert old.reload.superseded_at
    assert_equal BigDecimal("10.125"), old.value
    assert_equal 2, meter.meter_readings.count
    assert_equal 1, meter.meter_readings.effective.count
    assert_not corrected.update(value: "12")
    assert_not corrected.destroy
  end

  test "meter removal requires a final value and cannot precede an existing reading" do
    meter = install
    MasterData::Readings.record!(meter: meter, attributes: { read_on: "2026-09-01", value: "99", kind: "interim" }, user: @clerk)
    assert_raises ActiveRecord::RecordInvalid do
      MasterData::Meters.retire!(meter: meter, removed_on: Date.new(2026, 6, 1), closing_value: "98", user: @admin)
    end
    assert_nil meter.reload.removed_on
    assert_not meter.update(removed_on: Date.new(2026, 10, 1))
  end

  test "contract and meter updates keep before and after values with actor" do
    record = contract
    MasterData::Change.save!(record, attributes: {}, user: @admin)
    MasterData::Change.save!(record, attributes: { notes: "Synthetische Vereinbarung" }, user: @clerk)
    event = AuditEvent.where(subject_id: record.id).last
    assert_equal @clerk.id, event.user_id
    assert_equal [ nil, "Synthetische Vereinbarung" ], event.changeset["notes"]
    assert_equal @plant.id, event.plant_id
    assert event.occurred_at
  end
  test "boundary reading types cannot invent installation or removal events" do
    meter = install
    %w[installation removal].each do |kind|
      assert_raises ActiveRecord::RecordInvalid do
        MasterData::Readings.record!(meter: meter, attributes: { read_on: "2026-02-01", value: "20", kind: kind }, user: @clerk)
      end
    end
  end
end
