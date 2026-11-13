require "test_helper"
require_relative "../support/master_data_setup"

class MasterDataAccessTest < ActionDispatch::IntegrationTest
  include MasterDataSetup
  setup do
    Rails.cache.clear
    master_data
    @meter = install
    @foreign_meter = install(@foreign_connection)
    @contract = contract
    @contract.save!
  end

  def sign_in
    post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
    assert_response :see_other
  end

  test "all master data requires authentication" do
    get plant_customers_path(@plant)
    assert_redirected_to new_session_path
    post plant_connections_path(@plant), params: { connection: { number: "x", address: "x" } }
    assert_redirected_to new_session_path
  end

  test "authorized navigation forms and details render" do
    sign_in
    [ plant_customers_path(@plant), new_plant_customer_path(@plant), edit_plant_customer_path(@plant, @customer), plant_customer_path(@plant, @customer), plant_connections_path(@plant), new_plant_connection_path(@plant), edit_plant_connection_path(@plant, @connection), plant_connection_path(@plant, @connection), plant_route_sections_path(@plant), new_plant_route_section_path(@plant), edit_plant_route_section_path(@plant, @route), plant_heat_meters_path(@plant), new_plant_heat_meter_path(@plant), edit_plant_heat_meter_path(@plant, @meter), plant_heat_meter_path(@plant, @meter), replacement_plant_heat_meter_path(@plant, @meter), new_plant_heat_meter_meter_reading_path(@plant, @meter), plant_supply_contracts_path(@plant), new_plant_supply_contract_path(@plant), edit_plant_supply_contract_path(@plant, @contract), plant_supply_contract_path(@plant, @contract) ].each do |path|
      get path
      assert_response :success, path
    end
  end

  test "search and details do not leak foreign customers or contracts" do
    sign_in
    get plant_customers_path(@plant), params: { q: "Fremde" }
    assert_response :success
    assert_not_includes response.body, @foreign_customer.company_name
    get plant_customer_path(@plant, @foreign_customer)
    assert_response :not_found
    get plant_customers_path(@other)
    assert_response :not_found
    get plant_customers_path(@plant), params: { q: "%' OR 1=1 --" }
    assert_response :success
    assert_not_includes response.body, @foreign_customer.company_name
  end

  test "multiple plant permissions work without automatic global access" do
    @clerk.plant_permissions.create!(plant: @other)
    sign_in
    get plant_customer_path(@other, @foreign_customer)
    assert_response :success
    assert_includes response.body, @foreign_customer.company_name
    @clerk.plant_permissions.where(plant: @other).destroy_all
    get plant_customer_path(@other, @foreign_customer)
    assert_response :not_found
  end

  test "manipulated nested route connection meter reading and contract ids fail" do
    sign_in
    get plant_heat_meter_path(@plant, @foreign_meter)
    assert_response :not_found
    get new_plant_heat_meter_meter_reading_path(@plant, @foreign_meter)
    assert_response :not_found
    post plant_heat_meter_meter_readings_path(@plant, @meter), params: { meter_reading: { supersedes_id: @foreign_meter.meter_readings.first.id, read_on: "2026-01-01", value: "0", kind: "correction", comment: "x" } }
    assert_response :not_found
    patch plant_connection_path(@plant, @connection), params: { connection: { number: "x", route_section_id: @other.route_sections.create!(name: "Fremd").id } }
    assert_response :not_found
    assert_no_difference "SupplyContract.count" do
      post plant_supply_contracts_path(@plant), params: { supply_contract: { customer_membership_id: @foreign_membership.id, connection_id: @connection.id, number: "bad", starts_on: "2027-01-01", status: "active" } }
      assert_response :not_found
    end
    patch plant_supply_contract_path(@plant, @contract), params: { supply_contract: { customer_membership_id: @foreign_membership.id } }
    assert_response :unprocessable_entity
    assert_equal @membership.id, @contract.reload.customer_membership_id
    post link_plant_customers_path(@plant), params: { customer_id: @foreign_customer.id }
    assert_response :not_found
  end

  test "shared customer cannot be globally edited without all plant permissions" do
    @other.customer_memberships.create!(customer: @customer, customer_number: "SHARED")
    @other.supply_contracts.create!(connection: @foreign_connection, customer_membership: @other.customer_memberships.find_by!(customer: @customer), number: "HIDDEN-CONTRACT", starts_on: "2026-01-01", status: "active")
    sign_in
    get plant_customer_path(@plant, @customer)
    assert_response :success
    assert_not_includes response.body, "HIDDEN-CONTRACT"
    assert_not_includes response.body, @foreign_connection.address
    patch plant_customer_path(@plant, @customer), params: { customer: { address: "Manipulated" } }
    assert_response :forbidden
    assert_equal "Musterweg 3", @customer.reload.address
    patch plant_customer_path(@plant, @customer), params: { customer_membership: { active: "0" } }
    assert_response :see_other
    assert_not @membership.reload.active?
    @clerk.plant_permissions.create!(plant: @other)
    patch plant_customer_path(@plant, @customer), params: { customer: { address: "Neue synthetische Anschrift" } }
    assert_response :see_other
    assert_equal "Neue synthetische Anschrift", @customer.reload.address
  end

  test "customer create update filters uuid and plant injection and escapes HTML" do
    sign_in
    assert_difference "Customer.count", 1 do
      post plant_customers_path(@plant), params: { customer: { id: @foreign_customer.id, operator_id: -1, company_name: "<script>test</script>", address: "Testadresse" }, customer_membership: { plant_id: @other.id, customer_number: "NEW" } }
      assert_response :see_other
    end
    customer = Customer.find_by!(company_name: "<script>test</script>")
    assert_equal @plant.id, customer.customer_memberships.sole.plant_id
    get plant_customer_path(@plant, customer)
    assert_includes response.body, "&lt;script&gt;test&lt;/script&gt;"
    assert_select "script", text: "test", count: 0
    patch plant_customer_path(@plant, customer), params: { customer: { company_name: "Firma Neu" }, customer_membership: { customer_number: "EDIT" } }
    assert_response :see_other
    assert_equal "Firma Neu", customer.reload.company_name
    assert_equal "EDIT", customer.customer_memberships.sole.customer_number
  end

  test "contract overlap returns readable errors and no partial audit" do
    sign_in
    assert_no_difference [ "SupplyContract.count", "AuditEvent.count" ] do
      post plant_supply_contracts_path(@plant), params: { supply_contract: { customer_membership_id: @membership.id, connection_id: @connection.id, number: "OVERLAP", starts_on: "2026-02-01", status: "active" } }
      assert_response :unprocessable_entity
      assert_includes response.body, "überschneidet"
    end
  end

  test "readings ignore injected actor value and support traceable correction" do
    sign_in
    post plant_heat_meter_meter_readings_path(@plant, @meter), params: { meter_reading: { read_on: "2026-03-01", value: "20.123456", kind: "interim", recorded_by_id: @admin.id } }
    assert_response :see_other
    reading = @meter.meter_readings.find_by!(read_on: "2026-03-01")
    assert_equal @clerk.id, reading.recorded_by_id
    post plant_heat_meter_meter_readings_path(@plant, @meter), params: { meter_reading: { read_on: "2026-03-01", value: "19.5", kind: "correction", comment: "Synthetischer Tippfehler", supersedes_id: reading.id } }
    assert_response :see_other
    assert reading.reload.superseded_at
    assert_equal BigDecimal("20.123456"), reading.value
  end

  test "no delete routes exist for historical entities" do
    sign_in
    assert_no_difference [ "Customer.count", "Connection.count", "HeatMeter.count", "MeterReading.count", "SupplyContract.count" ] do
      delete plant_customer_path(@plant, @customer)
      assert_response :not_found
      delete plant_supply_contract_path(@plant, @contract)
      assert_response :not_found
    end
  end

  test "sensitive request payloads and queries are filtered" do
    filters = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filtered = filters.filter({ "customer" => { "address" => "PRIVATE-ADDRESS" }, "q" => "PRIVATE-SEARCH", "supply_contract" => { "notes" => "PRIVATE-NOTES" } })
    assert_not_includes filtered.to_s, "PRIVATE-ADDRESS"
    assert_not_includes filtered.to_s, "PRIVATE-SEARCH"
    assert_not_includes filtered.to_s, "PRIVATE-NOTES"
    assert_equal :info, Rails.application.config.log_level
  end
  test "real request logs do not contain contact fields search text or login identity" do
    buffer = StringIO.new
    capture = ActiveSupport::Logger.new(buffer)
    capture.level = Logger::INFO
    Rails.logger.broadcast_to(capture)
    post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
    post plant_customers_path(@plant), params: { customer: { company_name: "PRIVATE-COMPANY-LOG-PROBE", address: "PRIVATE-ADDRESS-LOG-PROBE", email: "private-log-probe@example.test" } }
    assert_response :see_other
    get plant_customers_path(@plant), params: { q: "PRIVATE-QUERY-LOG-PROBE" }
    assert_response :success
    [ "PRIVATE-COMPANY-LOG-PROBE", "PRIVATE-ADDRESS-LOG-PROBE", "private-log-probe@example.test", "PRIVATE-QUERY-LOG-PROBE", @clerk.email_address ].each do |value|
      assert_not_includes buffer.string, value
    end
    assert_includes buffer.string, "[FILTERED]"
  ensure
    Rails.logger.stop_broadcasting_to(capture) if capture
  end

  test "failed membership edit rolls back shared contact data and audit" do
    @plant.customer_memberships.create!(customer: @foreign_customer, customer_number: "OCCUPIED")
    sign_in
    assert_no_difference "AuditEvent.count" do
      patch plant_customer_path(@plant, @customer), params: { customer: { address: "Must roll back" }, customer_membership: { customer_number: "OCCUPIED" } }
      assert_response :unprocessable_entity
    end
    assert_equal "Musterweg 3", @customer.reload.address
    assert_equal "100", @membership.reload.customer_number
  end

  test "every foreign nested record remains unreachable for reads and writes" do
    foreign_contract = @other.supply_contracts.create!(customer_membership: @foreign_membership, connection: @foreign_connection, number: "FOREIGN", starts_on: "2026-01-01", status: "active")
    sign_in
    [ plant_customer_path(@plant, @foreign_customer), plant_connection_path(@plant, @foreign_connection), plant_heat_meter_path(@plant, @foreign_meter), plant_supply_contract_path(@plant, foreign_contract) ].each do |path|
      get path
      assert_response :not_found
    end
    patch plant_customer_path(@plant, @foreign_customer), params: { customer: { company_name: "Forbidden" } }
    assert_response :not_found
    patch plant_connection_path(@plant, @foreign_connection), params: { connection: { number: "Forbidden" } }
    assert_response :not_found
    patch plant_heat_meter_path(@plant, @foreign_meter), params: { heat_meter: { serial_number: "Forbidden" } }
    assert_response :not_found
    patch plant_supply_contract_path(@plant, foreign_contract), params: { supply_contract: { number: "Forbidden" } }
    assert_response :not_found
    assert_equal "FOREIGN", foreign_contract.reload.number
    assert_equal "Fremde Testfirma", @foreign_customer.reload.company_name
  end
end
