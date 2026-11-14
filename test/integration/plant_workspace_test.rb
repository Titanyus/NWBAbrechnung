require "test_helper"
require_relative "../support/master_data_setup"

class PlantWorkspaceTest < ActionDispatch::IntegrationTest
  include MasterDataSetup

  setup do
    Rails.cache.clear
    master_data
    post session_path, params: { email_address: @admin.email_address, password: "Synthetic-Password-2026" }
  end

  test "table counts relationships without join multiplication and scopes search" do
    contract.save!
    route = @plant.route_sections.create!(name: "Zweite Trasse")
    connection = @plant.connections.create!(number: "A-2", address: "Zweiter Anschluss", route_section: route)
    contract(connection: connection).save!
    get plants_path, params: { q: @plant.name }
    assert_response :success
    assert_select "#plants-table tbody tr", count: 1
    assert_select "#plants-table tbody tr td.number", text: "2", count: 3
    assert_select "#plant-search[data-live-search]"
    assert_includes response.body, "nicht erfasst"
    assert_select "nav[aria-label=Hauptnavigation] a[aria-current=page]", text: "Anlagen"
    delete session_path
    post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
    get plants_path, params: { q: @other.name, selected_plant_id: @other.id }
    assert_select "#plants-table tbody tr", count: 0
    assert_select "a", text: "Anlage bearbeiten", count: 0
  end

  test "plant list is bounded but live query searches beyond first page" do
    101.times do |index|
      Plants::Create.call(user: @admin, attributes: { name: format("Anlage %03d", index), address: "Testadresse" })
    end
    get plants_path
    assert_select "#plants-table tbody tr", count: 100
    get plants_path, params: { q: "Anlage 100" }
    assert_select "#plants-table tbody tr", count: 1
    assert_select "#plants-table tbody td a", text: "Anlage 100"
  end

  test "authorized administrator edits only permitted fields and produces audit" do
    patch plant_path(@plant), params: { plant: { name: "Neu", address: "Neue Anschrift", technical_notes: "Technik", operator_id: "invalid", id: @other.id } }
    assert_redirected_to plants_path(selected_plant_id: @plant.id)
    assert_equal "Neu", @plant.reload.name
    assert_equal @operator.id, @plant.operator_id
    event = AuditEvent.where(subject_type: "Plant", subject_id: @plant.id).last
    assert_equal @admin.id, event.user_id
    assert_equal @plant.id, event.plant_id
    assert_includes event.changeset.keys, "name"
  end

  test "invalid edit keeps errors and values" do
    patch plant_path(@plant), params: { plant: { name: "", address: "Eingabe bleibt" } }
    assert_response :unprocessable_entity
    assert_select "[role=alert]"
    assert_select "textarea#plant_address", text: "Eingabe bleibt"
    assert_not_equal "", @plant.reload.name
  end

  test "unassigned administrator cannot edit and clerk cannot update assigned plant" do
    @admin.plant_permissions.find_by!(plant: @other).destroy!
    get edit_plant_path(@other)
    assert_response :not_found
    patch plant_path(@other), params: { plant: { name: "bad" } }
    assert_response :not_found
    delete session_path
    post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
    get edit_plant_path(@plant)
    assert_response :forbidden
    patch plant_path(@plant), params: { plant: { name: "bad" } }
    assert_response :forbidden
    assert_not_equal "bad", @plant.reload.name
  end

  test "selection uses same authorized plant switch and opens contracts" do
    patch plant_selection_path, params: { selected_plant_id: @plant.id, area: "contracts" }
    assert_redirected_to plant_supply_contracts_path(@plant)
    get plants_path
    assert_select "#plants-table tr[aria-selected=true]", count: 1
    assert_select "a[href=?]", edit_plant_path(@plant), text: "Anlage bearbeiten"
  end
end
