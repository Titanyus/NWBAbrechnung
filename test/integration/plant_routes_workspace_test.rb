require "test_helper"
require_relative "../support/master_data_setup"

class PlantRoutesWorkspaceTest < ActionDispatch::IntegrationTest
  include MasterDataSetup

  setup do
    Rails.cache.clear
    master_data
    contract(number: "active").save!
    contract(number: "draft", status: "draft").save!
    contract(number: "cancelled", status: "cancelled").save!
    contract(number: "ended", status: "ended", starts_on: "2025-01-01", ends_on: "2025-12-31").save!
    post session_path, params: { email_address: @admin.email_address, password: "Synthetic-Password-2026" }
  end

  def stream_headers
    { "Turbo-Frame" => "route_editor", "Accept" => "text/vnd.turbo-stream.html" }
  end

  test "direct edit and combined overview count every contract status without multiplying connections" do
    get plants_path
    assert_select "#plants-table input[type=radio]", count: 0
    assert_select "#plants-table a[href=?]", edit_plant_path(@plant), text: "Bearbeiten"
    get edit_plant_path(@plant)
    assert_select "#plant-form"
    assert_select "#plant_metrics [data-metric=contracts]", text: "4"
    assert_select "#plant_metrics [data-metric=connections]", text: "1"
    assert_select "#plant-routes-table tr[data-route-id=?] td.number", @route.id, text: "1", count: 1
    assert_select "#plant-routes-table tr[data-route-id=?] td.number", @route.id, text: "4", count: 1
    assert_select "a", text: /Löschen|Entfernen/, count: 0
  end

  test "new plant has structured address and creates before routes" do
    get new_plant_path
    assert_select "#plant-form input#plant_street[required]"
    assert_select "#plant-form input#plant_postal_code[required]"
    assert_select "#plant-form input#plant_city[required]"
    assert_select "textarea#plant_address", count: 0
    assert_includes response.body, "Speichern Sie zuerst die Anlage"
    assert_select "#plant_metrics [data-metric=routes]", text: "0"
    post plants_path, params: { plant: { name: "Neue Anlage", street: "Neue Straße 1", postal_code: "01234", city: "Neustadt" } }
    created = Plant.find_by!(name: "Neue Anlage")
    assert_redirected_to edit_plant_path(created)
    assert_equal "01234", created.postal_code
    assert_equal "Neue Straße 1\n01234 Neustadt", created.address
  end

  test "inline route create and update replace routes and metrics only and audit" do
    assert_difference "RouteSection.count", 1 do
      post plant_route_sections_path(@plant), params: { within_plant: "1", route_section: { name: "Ost", code: "T-02", plant_id: @other.id } }, headers: stream_headers
      assert_response :success
    end
    created = @plant.route_sections.find_by!(code: "T-02")
    assert_select 'turbo-stream[target="plant_routes"]'
    assert_select 'turbo-stream[target="plant_metrics"]'
    assert_select 'turbo-stream[target="plant-form"]', count: 0
    assert_select "[data-metric=routes]", text: "2"
    assert AuditEvent.exists?(subject_type: "RouteSection", subject_id: created.id, user_id: @admin.id)
    patch plant_route_section_path(@plant, created), params: { within_plant: "1", route_section: { name: "Ost bearbeitet" } }, headers: stream_headers
    assert_response :success
    assert_equal "Ost bearbeitet", created.reload.name
  end

  test "invalid route keeps entered values in the editor without creating anything" do
    assert_no_difference "RouteSection.count" do
      post plant_route_sections_path(@plant), params: { within_plant: "1", route_section: { name: "", code: "BLEIBT" } }, headers: stream_headers
      assert_response :unprocessable_entity
    end
    assert_select "turbo-frame#route_editor"
    assert_select "#route_section_code[value=?]", "BLEIBT"
    assert_select "[role=alert]"
  end

  test "route access and association manipulation stay scoped and assigned clerk keeps route rights" do
    foreign = @other.route_sections.create!(name: "Fremde Trasse")
    delete session_path
    post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
    get plant_path(@plant)
    assert_select "#plant-form", count: 0
    assert_select "a", text: "Neue Trasse", count: 1
    get edit_plant_route_section_path(@plant, foreign), params: { within_plant: "1" }
    assert_response :not_found
    patch plant_route_section_path(@plant, foreign), params: { within_plant: "1", route_section: { name: "bad" } }, headers: stream_headers
    assert_response :not_found
    post plant_route_sections_path(@other), params: { within_plant: "1", route_section: { name: "bad" } }, headers: stream_headers
    assert_response :not_found
    post plant_route_sections_path(@plant), params: { within_plant: "1", route_section: { name: "Erlaubt" } }, headers: stream_headers
    assert_response :success
    patch plant_connection_path(@plant, @connection), params: { connection: { route_section_id: foreign.id } }
    assert_response :not_found
    assert_equal @route.id, @connection.reload.route_section_id
  end

  test "occupied route cannot be deleted through HTTP or model and revoked rights block editor" do
    assert_no_difference "RouteSection.count" do
      delete plant_route_section_path(@plant, @route)
      assert_response :not_found
    end
    assert_raises(ActiveRecord::DeleteRestrictionError) { @route.destroy! }
    @admin.plant_permissions.where(plant: @plant).destroy_all
    get new_plant_route_section_path(@plant), params: { within_plant: "1" }
    assert_response :not_found
  end

  test "route section has no search and pagination remains available only for exceptional large lists" do
    get plant_path(@plant)
    assert_select "#route-search", count: 0
    assert_select "#plant_routes nav[aria-label=Ergebnisseiten]", count: 0
    101.times { |i| @plant.route_sections.create!(name: format("Trasse %03d", i), code: "T#{i}") }
    get plant_path(@plant), headers: { "Turbo-Frame" => "plant_routes" }
    assert_select "#plant-routes-table tbody tr", count: 100
    assert_select "#plant_routes nav[aria-label=Ergebnisseiten] a", text: "Nächste Seite →"
    get plant_path(@plant), params: { route_page: "2" }, headers: { "Turbo-Frame" => "plant_routes" }
    assert_select "#plant-routes-table tbody tr", count: 2
  end
end
