require "test_helper"
require_relative "../support/master_data_setup"

class ContractWorkspaceTest < ActionDispatch::IntegrationTest
  include MasterDataSetup
  setup do
    Rails.cache.clear
    master_data
    @meter = install
    @record = contract
    @record.save!
    post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
    assert_response :see_other
  end

  def stream_headers(frame)
    { "Turbo-Frame" => frame, "Accept" => "text/vnd.turbo-stream.html" }
  end

  test "overview includes all important groups together" do
    get plant_supply_contracts_path(@plant)
    assert_response :success
    assert_select "body.contract-desktop"
    assert_select "#contract_browser"
    assert_select ".contract-list-scroll"
    assert_select "turbo-frame#contract_detail #contract_customer"
    assert_select "#contract_connection"
    assert_select "#contract_terms"
    assert_select "#contract_meter"
    assert_includes response.body, @customer.display_name
    assert_includes response.body, @connection.address
    assert_includes response.body, @meter.serial_number
    assert_select "nav[aria-label=Hauptnavigation] a", count: 2
    assert_select "nav[aria-label=Hauptnavigation] a", text: "Kunden", count: 0
    assert_select "nav[aria-label=Ergebnisseiten]", count: 0
  end

  test "detail frame response does not render another results list" do
    get plant_supply_contract_path(@plant, @record), headers: { "Turbo-Frame" => "contract_detail" }
    assert_response :success
    assert_select "turbo-frame#contract_detail", count: 1
    assert_select ".contract-list-scroll", count: 0
    assert_select "#contract_customer"
  end

  test "deep links still open the complete authorized workspace" do
    get plant_supply_contract_path(@plant, @record)
    assert_response :success
    assert_select ".contract-list-scroll"
    assert_select "#contract_workspace[data-contract-id=?]", @record.id
  end

  test "history is a real scoped detail and overview stays together" do
    MasterData::Change.save!(@record, attributes: { notes: "Synthetic history" }, user: @clerk)
    get plant_supply_contract_path(@plant, @record), params: { tab: "history" }, headers: { "Turbo-Frame" => "contract_detail" }
    assert_response :success
    assert_select "#contract-history"
    assert_includes response.body, "Synthetic history"
    assert_select "#contract_customer", count: 0
  end

  test "customer edit in context updates the same workspace" do
    patch plant_customer_path(@plant, @customer), params: { contract_id: @record.id, customer: { phone: "0000-CONTEXT" } }, headers: stream_headers("contract_customer")
    assert_response :success
    assert_equal "0000-CONTEXT", @customer.reload.phone
    assert_select "turbo-stream[action=replace][target=contract_workspace]"
    assert_includes response.body, @record.number
  end

  test "reading in context records actor and refreshes current value" do
    post plant_heat_meter_meter_readings_path(@plant, @meter), params: { contract_id: @record.id, meter_reading: { read_on: "2026-03-01", value: "20.123456", kind: "interim", recorded_by_id: @admin.id } }, headers: stream_headers("contract_meter")
    assert_response :success
    assert_select "turbo-stream[target=contract_workspace]"
    assert_includes response.body, "20,123456"
    assert_equal @clerk.id, @meter.meter_readings.order(:read_on).last.recorded_by_id
  end

  test "plain HTML return ignores free redirect targets" do
    patch plant_customer_path(@plant, @customer), params: { contract_id: @record.id, return_to: "https://untrusted.invalid/", customer: { phone: "0000-SAFE" } }
    assert_redirected_to plant_supply_contract_path(@plant, @record)
  end

  test "mismatching authorized resources cannot borrow a contract context" do
    another = @operator.customers.create!(company_name: "Other customer", address: "Other address")
    @plant.customer_memberships.create!(customer: another)
    get edit_plant_customer_path(@plant, another), params: { contract_id: @record.id }
    assert_response :not_found
    other_connection = @plant.connections.create!(number: "Other", address: "Other")
    other_meter = install(other_connection)
    get new_plant_heat_meter_meter_reading_path(@plant, other_meter), params: { contract_id: @record.id }
    assert_response :not_found
    assert_no_difference [ "MeterReading.count", "AuditEvent.count" ] do
      post plant_heat_meter_meter_readings_path(@plant, other_meter), params: { contract_id: @record.id, meter_reading: { read_on: "2026-03-01", value: "22", kind: "interim" } }
      assert_response :not_found
    end
  end

  test "foreign contract context and direct ids are not exposed" do
    foreign = @other.supply_contracts.create!(number: "FOREIGN", connection: @foreign_connection, customer_membership: @foreign_membership, starts_on: "2026-01-01", status: "active")
    get plant_supply_contract_path(@plant, foreign)
    assert_response :not_found
    patch plant_customer_path(@plant, @customer), params: { contract_id: foreign.id, customer: { address: "bad" } }
    assert_response :not_found
    assert_equal "Musterweg 3", @customer.reload.address
  end

  test "shared customer permission rule remains effective in a frame" do
    @other.customer_memberships.create!(customer: @customer)
    patch plant_customer_path(@plant, @customer), params: { contract_id: @record.id, customer: { address: "bad" } }, headers: stream_headers("contract_customer")
    assert_response :forbidden
    assert_equal "Musterweg 3", @customer.reload.address
  end

  test "global plant selection remains scoped" do
    patch plant_selection_path, params: { selected_plant_id: @other.id, area: "contracts" }
    assert_response :not_found
    @clerk.plant_permissions.create!(plant: @other)
    patch plant_selection_path, params: { selected_plant_id: @other.id, area: "contracts", return_to: "https://untrusted.invalid" }
    assert_redirected_to plant_supply_contracts_path(@other)
  end

  test "cursor tampering is rejected without exposing results" do
    get plant_supply_contracts_path(@plant), params: { cursor: "invalid" }, headers: { "Turbo-Frame" => "contracts_page_30" }
    assert_response :bad_request
    assert_select "turbo-frame#contracts_page_30"
    assert_not_includes response.body, @customer.display_name
  end
end
