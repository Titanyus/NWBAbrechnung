require "test_helper"
require_relative "../support/master_data_setup"

class ContractCreationTest < ActionDispatch::IntegrationTest
  include MasterDataSetup

  setup do
    Rails.cache.clear
    master_data
    post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
  end

  def frame_headers
    { "Turbo-Frame" => "contract_detail", "Accept" => "text/html" }
  end

  def existing_params(number: "NEW")
    { contract_draft: { customer_mode: "existing", connection_mode: "existing", customer_membership_id: @membership.id, connection_id: @connection.id }, supply_contract: { number: number, starts_on: "2026-01-01", status: "draft" } }
  end

  def new_params
    { contract_draft: { customer_mode: "new", connection_mode: "new", meter_mode: "new" },
      customer: { company_name: "Neuer Kunde", street: "Kundenweg 1", postal_code: "00123", city: "Kundenort" },
      customer_membership: { customer_number: "NEU" },
      connection: { number: "NEW-H", street: "Hausweg 2", postal_code: "00456", city: "Hausort", route_section_id: @route.id },
      heat_meter: { serial_number: "NEW-M", installed_on: "2026-01-01", unit: "kWh", connection_id: @foreign_connection.id }, initial_value: "0.123456",
      supply_contract: { number: "NEW-V", starts_on: "2026-01-01", status: "active" } }
  end

  test "creation is a detail frame and a direct URL still renders master detail" do
    get plant_supply_contracts_path(@plant)
    assert_select 'a[data-turbo-frame="contract_detail"]', text: "Vertrag anlegen"
    get new_plant_supply_contract_path(@plant), headers: frame_headers
    assert_response :success
    assert_select "turbo-frame#contract_detail #contract-draft-form"
    assert_select ".contract-list-scroll", count: 0
    assert_select "#draft-customer-search[data-live-search]"
    assert_select "#draft-connection-search[data-live-search]"
    assert_select "#customer_street"
    assert_select "#record_connection_postal_code"
    get new_plant_supply_contract_path(@plant)
    assert_select ".contract-list-scroll"
    assert_select "#contract-draft-form"
    assert_select "h1", text: "Vertragsverwaltung"
    ids = css_select("[id]").map { |element| element["id"] }
    assert_equal ids.uniq.sort, ids.sort, "Shared inline fields must not duplicate global filter IDs"
  end

  test "existing records are reused and never overwritten by submitted creation fields" do
    params = existing_params
    params[:customer] = { company_name: "Must not overwrite", street: "other" }
    params[:connection] = { street: "Must not overwrite" }
    assert_no_difference [ "Customer.count", "CustomerMembership.count", "Connection.count", "HeatMeter.count" ] do
      assert_difference "SupplyContract.count", 1 do
        post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
        assert_response :see_other
      end
    end
    created = @plant.supply_contracts.find_by!(number: "NEW")
    assert_equal @membership.id, created.customer_membership_id
    assert_equal @connection.id, created.connection_id
    assert_equal "Musterweg 3", @customer.reload.street
    assert_equal "Testweg 1", @connection.reload.street
    follow_redirect! headers: frame_headers
    assert_select "#contract_workspace[data-contract-id=?]", created.id
    assert_select 'turbo-stream[target="contract_count"]'
  end

  test "new customer connection meter reading and contract save atomically in current plant" do
    assert_difference [ "Customer.count", "CustomerMembership.count", "Connection.count", "HeatMeter.count", "MeterReading.count", "SupplyContract.count" ], 1 do
      post plant_supply_contracts_path(@plant), params: new_params, headers: frame_headers
      assert_response :see_other
    end
    created = @plant.supply_contracts.find_by!(number: "NEW-V")
    assert_equal "00123", created.customer.postal_code
    assert_equal @plant.id, created.customer_membership.plant_id
    assert_equal @route.id, created.connection.route_section_id
    meter = created.connection.heat_meters.sole
    assert_equal "NEW-M", meter.serial_number
    assert_equal BigDecimal("0.123456"), meter.meter_readings.sole.value
    assert_equal @clerk.id, meter.meter_readings.sole.recorded_by_id
    assert AuditEvent.exists?(subject_type: "SupplyContract", subject_id: created.id, user: @clerk)
  end

  test "failed installation rolls back all new records and audit while retaining fields and modes" do
    params = new_params
    params[:initial_value] = "bad-number"
    assert_no_difference [ "Customer.count", "CustomerMembership.count", "Connection.count", "HeatMeter.count", "MeterReading.count", "SupplyContract.count", "AuditEvent.count" ] do
      post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
      assert_response :unprocessable_entity
    end
    assert_select "#contract_draft_workspace [role=alert]"
    assert_select '#customer_company_name[value="Neuer Kunde"]'
    assert_select '#record_connection_number[value="NEW-H"]'
    assert_select '#heat_meter_serial_number[value="NEW-M"]'
    assert_select "#contract_draft_customer_mode_new[checked]"
    assert_select "#contract_draft_connection_mode_new[checked]"
  end

  test "new connection and contract can save without a meter" do
    params = new_params
    params[:contract_draft][:meter_mode] = "none"
    params.delete(:heat_meter)
    assert_no_difference "HeatMeter.count" do
      post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
      assert_response :see_other
    end
  end

  test "active meter is shown and cannot be silently exchanged" do
    meter = install
    get draft_meter_plant_supply_contracts_path(@plant), params: { connection_id: @connection.id }
    assert_select "turbo-frame#draft_meter", text: /#{meter.serial_number}/
    assert_select "#draft_new_meter", count: 0
    params = existing_params
    params[:contract_draft][:meter_mode] = "new"
    params[:heat_meter] = { serial_number: "REPLACEMENT", installed_on: "2026-02-01", unit: "kWh" }
    params[:initial_value] = "0"
    assert_no_difference [ "HeatMeter.count", "SupplyContract.count", "AuditEvent.count" ] do
      post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
      assert_response :unprocessable_entity
    end
    assert_nil meter.reload.removed_on
    assert_equal @connection.id, meter.connection_id
  end

  test "foreign customers connections routes and meter requests are rejected" do
    foreign_route = @other.route_sections.create!(name: "Foreign")
    [ [ :customer_membership_id, @foreign_membership.id ], [ :connection_id, @foreign_connection.id ] ].each do |key, id|
      params = existing_params
      params[:contract_draft][key] = id
      post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
      assert_response :not_found
    end
    params = new_params
    params[:connection][:route_section_id] = foreign_route.id
    assert_no_difference [ "Customer.count", "Connection.count", "SupplyContract.count" ] do
      post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
      assert_response :not_found
    end
    get draft_meter_plant_supply_contracts_path(@plant), params: { connection_id: @foreign_connection.id }
    assert_response :not_found
    get draft_customers_plant_supply_contracts_path(@plant), params: { selected_id: @foreign_membership.id }
    assert_response :not_found
    get draft_connections_plant_supply_contracts_path(@plant), params: { selected_id: @foreign_connection.id }
    assert_response :not_found
  end

  test "lookup results are bounded and find beyond the initial window over all address fields" do
    25.times do |i|
      customer = @operator.customers.create!(company_name: format("Firma %02d", i), street: "Kundenweg #{i}", postal_code: "00123", city: "Kundenort")
      @plant.customer_memberships.create!(customer: customer, customer_number: "LOOK#{i}")
      @plant.connections.create!(number: "LOOK#{i}", street: "Hausweg #{i}", postal_code: "00456", city: "Hausort", route_section: @route)
    end
    get draft_customers_plant_supply_contracts_path(@plant)
    assert_select "#draft_customer_id option", count: 21
    get draft_customers_plant_supply_contracts_path(@plant), params: { q: "LOOK24" }
    assert_select "#draft_customer_id option", count: 2
    assert_select "#draft_customer_id", text: /Firma 24/
    get draft_connections_plant_supply_contracts_path(@plant), params: { q: "Hausweg 24" }
    assert_select "#draft_connection_id option", count: 2
    get draft_connections_plant_supply_contracts_path(@plant), params: { q: "00456" }
    assert_select "#draft_connection_id option", count: 21
    get draft_connections_plant_supply_contracts_path(@plant), params: { q: @route.name }
    assert_select "#draft_connection_id option", count: 21
  end

  test "existing shared customer can be reused with new connection without changing contact data" do
    @other.customer_memberships.create!(customer: @customer)
    params = new_params
    params[:contract_draft].merge!(customer_mode: "existing", customer_membership_id: @membership.id, meter_mode: "none")
    assert_no_difference [ "Customer.count", "CustomerMembership.count" ] do
      assert_difference [ "Connection.count", "SupplyContract.count" ], 1 do
        post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
        assert_response :see_other
      end
    end
    assert_equal "Musterweg 3", @customer.reload.street
    assert_equal @membership.id, @plant.supply_contracts.find_by!(number: "NEW-V").customer_membership_id
  end

  test "new customer can use existing connection and resubmitting does not duplicate objects" do
    params = new_params
    params[:contract_draft].merge!(connection_mode: "existing", connection_id: @connection.id, meter_mode: "none")
    assert_no_difference "Connection.count" do
      post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
      assert_response :see_other
    end
    assert_equal @connection.id, @plant.supply_contracts.find_by!(number: "NEW-V").connection_id
    assert_no_difference [ "Customer.count", "CustomerMembership.count", "Connection.count", "HeatMeter.count", "SupplyContract.count", "AuditEvent.count" ] do
      post plant_supply_contracts_path(@plant), params: params, headers: frame_headers
      assert_response :unprocessable_entity
    end
  end

  test "revoked plant rights block form and lookup access" do
    @clerk.plant_permissions.destroy_all
    [ new_plant_supply_contract_path(@plant), draft_customers_plant_supply_contracts_path(@plant), draft_connections_plant_supply_contracts_path(@plant), draft_meter_plant_supply_contracts_path(@plant) ].each do |path|
      get path
      assert_response :not_found
    end
    assert_raises(ActiveRecord::RecordNotFound) { Contracts::Draft.new(plant: @other, user: @clerk) }
  end
end
