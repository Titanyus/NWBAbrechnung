require "test_helper"

class AccessTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    foundation
  end

  def sign_in(user = @clerk)
    post session_path, params: { email_address: user.email_address, password: "Synthetic-Password-2026" }
    assert_response :see_other
  end

  test "anonymous access requires login" do
    get plants_path
    assert_redirected_to new_session_path
    post plants_path, params: { plant: { name: "No", street: "No", postal_code: "00000", city: "Testort" } }
    assert_redirected_to new_session_path
  end

  test "invalid credentials and inactive account cannot log in" do
    assert_no_difference "Session.count" do
      post session_path, params: { email_address: @clerk.email_address, password: "wrong" }
      assert_response :unprocessable_entity
      @clerk.update!(active: false)
      post session_path, params: { email_address: @clerk.email_address, password: "Synthetic-Password-2026" }
      assert_response :unprocessable_entity
    end
  end

  test "login scope direct ID and revoked access" do
    sign_in
    get plants_path
    assert_response :success
    assert_select "#plants-table tbody td a", text: "Test Nord"
    assert_select "#plants-table tbody td a", text: "Test Süd", count: 0
    get plant_path(@other)
    assert_response :not_found
    get plant_path(@plant)
    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    @clerk.plant_permissions.destroy_all
    get plant_path(@plant)
    assert_response :not_found
  end

  test "administrator also needs explicit plant access" do
    @admin.plant_permissions.where(plant: @other).destroy_all
    sign_in(@admin)
    get plant_path(@other)
    assert_response :not_found
  end

  test "clerk cannot create or escalate role" do
    sign_in
    get new_plant_path
    assert_response :forbidden
    assert_no_difference "Plant.count" do
      post plants_path, params: { administrator: true, plant: { name: "No", street: "No", postal_code: "00000", city: "Testort" } }
      assert_response :forbidden
    end
  end

  test "creation grants creator only and audits atomically" do
    sign_in(@admin)
    assert_difference [ "Plant.count", "PlantPermission.count", "AuditEvent.count" ], 1 do
      post plants_path, params: { plant: { name: "Neue Anlage", street: "Testweg", postal_code: "00000", city: "Testort", operator_id: 123, user_ids: [ @clerk.id ] } }
      assert_response :see_other
    end
    plant = Plant.find_by!(name: "Neue Anlage")
    assert_equal @operator, plant.operator
    assert @admin.plants.exists?(plant.id)
    assert_not @clerk.plants.exists?(plant.id)
    assert_equal @admin, AuditEvent.last.user
    assert_no_difference [ "Plant.count", "PlantPermission.count", "AuditEvent.count" ] do
      post plants_path, params: { plant: { name: "", street: "", postal_code: "00000", city: "Testort" } }
      assert_response :unprocessable_entity
    end
  end

  test "logout and password change revoke session" do
    sign_in
    delete session_path
    assert_response :see_other
    get plants_path
    assert_redirected_to new_session_path
    sign_in
    @clerk.update!(password: "Changed-Synthetic-Password-2026")
    get plants_path
    assert_redirected_to new_session_path
  end

  test "expired session and disabled user lose access" do
    sign_in
    @clerk.sessions.update_all(expires_at: 1.minute.ago)
    get plants_path
    assert_redirected_to new_session_path
    sign_in
    @clerk.update!(active: false)
    get plants_path
    assert_redirected_to new_session_path
  end


  test "appearance is authenticated and only exposes presentation controls" do
    get appearance_path
    assert_redirected_to new_session_path
    sign_in
    get appearance_path
    assert_response :success
    assert_select "select#theme-preset option", count: 4
    assert_select "select#theme-mode option", count: 2
    assert_select "input[type=color]", count: 1
  end

  test "plant content is escaped in HTML" do
    @plant.update!(name: "<script>bad()</script>", technical_notes: "<img src=x onerror=bad()>")
    sign_in
    get plant_path(@plant)
    assert_response :success
    assert_includes response.body, "&lt;script&gt;bad()&lt;/script&gt;"
    assert_select "img[onerror]", count: 0
  end

  test "login rate limit is enforced" do
    Rails.cache.clear
    10.times { post session_path, params: { email_address: "absent@example.test", password: "wrong" } }
    post session_path, params: { email_address: "absent@example.test", password: "wrong" }
    assert_response :too_many_requests
  ensure
    Rails.cache.clear
  end
end
