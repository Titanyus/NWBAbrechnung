require "test_helper"

class PlantRemovalTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    foundation
    post session_path, params: { email_address: @admin.email_address, password: "Synthetic-Password-2026" }
  end

  def confirmation(plant = @plant)
    get delete_confirmation_plant_path(plant)
    assert_response :success
    token = css_select('input[name="confirmation"]').first
    token&.attr("value")
  end

  test "top action asks confirmation and cancel leaves plant unchanged" do
    get edit_plant_path(@plant)
    assert_select ".page-heading a[href=?]", delete_confirmation_plant_path(@plant), text: "Anlage löschen"
    confirmation
    assert_select "h2", text: /wirklich löschen/
    assert_select "a[href=?]", edit_plant_path(@plant), text: "Abbrechen"
    assert_nil @plant.reload.deleted_at
    assert @admin.plants.exists?(@plant.id)
  end

  test "confirmed removal hides plant everywhere while preserving existing audit records" do
    original_audits = AuditEvent.where(plant: @plant).pluck(:id)
    token = confirmation
    assert_difference "AuditEvent.count", 1 do
      delete plant_path(@plant), params: { confirmation: token }
      assert_redirected_to plants_path
    end
    assert @plant.reload.deleted_at
    assert_not @admin.plants.exists?(@plant.id)
    assert_not @clerk.plants.exists?(@plant.id)
    assert_equal original_audits, AuditEvent.where(id: original_audits).pluck(:id)
    assert AuditEvent.exists?(plant: @plant, action: "plant.deleted", user: @admin)
    get plants_path
    assert_select "#plants-table a", text: @plant.name, count: 0
    assert_select "#selected_plant_id option[value=?]", @plant.id, count: 0
    [ plant_path(@plant), edit_plant_path(@plant), plant_supply_contracts_path(@plant), new_plant_route_section_path(@plant) ].each do |path|
      get path
      assert_response :not_found
    end
    post plant_route_sections_path(@plant), params: { route_section: { name: "Zu spät" } }
    assert_response :not_found
  end

  test "missing tampered expired and other-plant confirmations never remove" do
    [ nil, "bad", confirmation(@other) ].each do |token|
      delete plant_path(@plant), params: { confirmation: token }
      assert_redirected_to delete_confirmation_plant_path(@plant)
      assert_nil @plant.reload.deleted_at
    end
    token = confirmation
    travel 11.minutes do
      delete plant_path(@plant), params: { confirmation: token }
      assert_redirected_to delete_confirmation_plant_path(@plant)
      assert_nil @plant.reload.deleted_at
    end
  end

  test "changed plant requires renewed confirmation and new relationships block removal" do
    token = confirmation
    @plant.update!(technical_notes: "Geändert")
    delete plant_path(@plant), params: { confirmation: token }
    assert_redirected_to delete_confirmation_plant_path(@plant)
    assert_nil @plant.reload.deleted_at
    token = confirmation
    @plant.route_sections.create!(name: "Neu zugeordnet")
    delete plant_path(@plant), params: { confirmation: token }
    assert_redirected_to edit_plant_path(@plant)
    assert_nil @plant.reload.deleted_at
    confirmation
    assert_select "button", text: "Löschen bestätigen", count: 0
    assert_includes response.body, "kann nicht gelöscht werden"
  end

  test "confirmation belongs to its actor and only assigned administrators may remove" do
    token = confirmation
    delete session_path
    post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
    get plant_path(@plant)
    assert_select "a", text: "Anlage löschen", count: 0
    get delete_confirmation_plant_path(@plant)
    assert_response :forbidden
    delete plant_path(@plant), params: { confirmation: token }
    assert_response :forbidden
    @clerk.update!(administrator: true)
    delete plant_path(@plant), params: { confirmation: token }
    assert_redirected_to delete_confirmation_plant_path(@plant)
    @clerk.plant_permissions.destroy_all
    delete plant_path(@plant), params: { confirmation: token }
    assert_response :not_found
    assert_nil @plant.reload.deleted_at
  end
end
