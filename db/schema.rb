# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_14_000200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.uuid "plant_id", null: false
    t.string "action", null: false
    t.datetime "occurred_at", null: false
    t.string "subject_type"
    t.uuid "subject_id"
    t.jsonb "changeset", default: {}, null: false
    t.index ["plant_id"], name: "index_audit_events_on_plant_id"
    t.index ["user_id"], name: "index_audit_events_on_user_id"
  end

  create_table "connections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "plant_id", null: false
    t.uuid "route_section_id"
    t.string "number", null: false
    t.text "street", null: false
    t.date "commissioned_on"
    t.string "technical_status", default: "active", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "postal_code", limit: 20, null: false
    t.string "city", limit: 200, null: false
    t.index ["id", "plant_id"], name: "index_connections_on_id_and_plant_id", unique: true
    t.index ["plant_id", "number"], name: "index_connections_on_plant_id_and_number", unique: true
    t.index ["plant_id"], name: "index_connections_on_plant_id"
    t.check_constraint "length(TRIM(BOTH FROM number)) > 0 AND length(TRIM(BOTH FROM street)) > 0", name: "connection_required_fields"
    t.check_constraint "length(TRIM(BOTH FROM street)) >= 1 AND length(TRIM(BOTH FROM street)) <= 500 AND length(TRIM(BOTH FROM postal_code)) >= 1 AND length(TRIM(BOTH FROM postal_code)) <= 20 AND length(TRIM(BOTH FROM city)) >= 1 AND length(TRIM(BOTH FROM city)) <= 200 AND POSITION((chr(10)) IN ((street || postal_code::text) || city::text)) = 0 AND POSITION((chr(13)) IN ((street || postal_code::text) || city::text)) = 0", name: "connections_structured_address"
    t.check_constraint "technical_status::text = ANY (ARRAY['planned'::character varying::text, 'active'::character varying::text, 'inactive'::character varying::text])", name: "connection_status"
  end

  create_table "customer_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.uuid "plant_id", null: false
    t.string "customer_number"
    t.string "payment_method", default: "bank_transfer", null: false
    t.boolean "direct_debit_agreement", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "plant_id"], name: "index_customer_memberships_on_customer_id_and_plant_id", unique: true
    t.index ["customer_id"], name: "index_customer_memberships_on_customer_id"
    t.index ["id", "plant_id"], name: "index_customer_memberships_on_id_and_plant_id", unique: true
    t.index ["plant_id", "customer_number"], name: "index_customer_memberships_on_plant_id_and_customer_number", unique: true, where: "(customer_number IS NOT NULL)"
    t.index ["plant_id"], name: "index_customer_memberships_on_plant_id"
    t.check_constraint "payment_method::text = ANY (ARRAY['bank_transfer'::character varying::text, 'direct_debit'::character varying::text, 'cash'::character varying::text, 'other'::character varying::text])", name: "membership_payment_method"
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "operator_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.text "street", null: false
    t.string "phone"
    t.string "email"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "postal_code", limit: 20, null: false
    t.string "city", limit: 200, null: false
    t.index ["operator_id"], name: "index_customers_on_operator_id"
    t.check_constraint "length(TRIM(BOTH FROM COALESCE(company_name, ''::character varying))) > 0 OR length(TRIM(BOTH FROM COALESCE(first_name, ''::character varying))) > 0 AND length(TRIM(BOTH FROM COALESCE(last_name, ''::character varying))) > 0", name: "customer_identity_present"
    t.check_constraint "length(TRIM(BOTH FROM street)) > 0", name: "customer_address_present"
    t.check_constraint "length(TRIM(BOTH FROM street)) >= 1 AND length(TRIM(BOTH FROM street)) <= 500 AND length(TRIM(BOTH FROM postal_code)) >= 1 AND length(TRIM(BOTH FROM postal_code)) <= 20 AND length(TRIM(BOTH FROM city)) >= 1 AND length(TRIM(BOTH FROM city)) <= 200 AND POSITION((chr(10)) IN ((street || postal_code::text) || city::text)) = 0 AND POSITION((chr(13)) IN ((street || postal_code::text) || city::text)) = 0", name: "customers_structured_address"
  end

  create_table "heat_meters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "connection_id", null: false
    t.string "serial_number", null: false
    t.date "installed_on", null: false
    t.date "removed_on"
    t.string "unit", default: "kWh", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["connection_id"], name: "index_heat_meters_on_connection_id"
    t.check_constraint "(unit::text = ANY (ARRAY['kWh'::character varying::text, 'MWh'::character varying::text])) AND length(TRIM(BOTH FROM serial_number)) > 0", name: "meter_required_fields"
    t.check_constraint "removed_on IS NULL OR removed_on > installed_on", name: "meter_date_order"
    t.exclusion_constraint "connection_id WITH =, daterange(installed_on, removed_on, '[)'::text) WITH &&", using: :gist, name: "no_overlapping_heat_meters"
  end

  create_table "meter_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "heat_meter_id", null: false
    t.date "read_on", null: false
    t.decimal "value", precision: 20, scale: 6, null: false
    t.string "kind", null: false
    t.text "comment"
    t.bigint "recorded_by_id", null: false
    t.datetime "recorded_at", null: false
    t.uuid "supersedes_id"
    t.datetime "superseded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["heat_meter_id", "read_on"], name: "one_effective_reading_per_day", unique: true, where: "(superseded_at IS NULL)"
    t.index ["heat_meter_id"], name: "index_meter_readings_on_heat_meter_id"
    t.index ["id", "heat_meter_id"], name: "index_meter_readings_on_id_and_heat_meter_id", unique: true
    t.index ["recorded_by_id"], name: "index_meter_readings_on_recorded_by_id"
    t.index ["supersedes_id"], name: "index_meter_readings_on_supersedes_id", unique: true
    t.check_constraint "kind::text <> 'correction'::text OR length(TRIM(BOTH FROM COALESCE(comment, ''::text))) > 0", name: "correction_requires_reason"
    t.check_constraint "kind::text = ANY (ARRAY['annual'::character varying::text, 'interim'::character varying::text, 'installation'::character varying::text, 'removal'::character varying::text, 'correction'::character varying::text])", name: "reading_kind"
    t.check_constraint "value >= 0::numeric", name: "reading_nonnegative"
  end

  create_table "operators", force: :cascade do |t|
    t.string "name", null: false
    t.integer "singleton_key", default: 1, null: false
    t.uuid "source_id", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["singleton_key"], name: "index_operators_on_singleton_key", unique: true
    t.index ["source_id"], name: "index_operators_on_source_id", unique: true
    t.check_constraint "length(TRIM(BOTH FROM name)) > 0", name: "operator_name_present"
    t.check_constraint "singleton_key = 1", name: "one_operator"
  end

  create_table "plant_permissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.uuid "plant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id"], name: "index_plant_permissions_on_plant_id"
    t.index ["user_id", "plant_id"], name: "index_plant_permissions_on_user_id_and_plant_id", unique: true
    t.index ["user_id"], name: "index_plant_permissions_on_user_id"
  end

  create_table "plants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "operator_id", null: false
    t.string "name", null: false
    t.text "street", null: false
    t.text "technical_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "postal_code", limit: 20, null: false
    t.string "city", limit: 200, null: false
    t.datetime "deleted_at"
    t.index ["operator_id"], name: "index_plants_on_operator_id"
    t.check_constraint "length(TRIM(BOTH FROM name)) > 0 AND length(TRIM(BOTH FROM street)) > 0", name: "plant_required_fields"
    t.check_constraint "length(TRIM(BOTH FROM street)) >= 1 AND length(TRIM(BOTH FROM street)) <= 500 AND length(TRIM(BOTH FROM postal_code)) >= 1 AND length(TRIM(BOTH FROM postal_code)) <= 20 AND length(TRIM(BOTH FROM city)) >= 1 AND length(TRIM(BOTH FROM city)) <= 200 AND POSITION((chr(10)) IN ((street || postal_code::text) || city::text)) = 0 AND POSITION((chr(13)) IN ((street || postal_code::text) || city::text)) = 0", name: "plants_structured_address"
  end

  create_table "route_sections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "plant_id", null: false
    t.string "name", null: false
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "plant_id"], name: "index_route_sections_on_id_and_plant_id", unique: true
    t.index ["plant_id"], name: "index_route_sections_on_plant_id"
    t.check_constraint "length(TRIM(BOTH FROM name)) > 0", name: "route_name_present"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "supply_contracts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "plant_id", null: false
    t.uuid "customer_membership_id", null: false
    t.uuid "connection_id", null: false
    t.string "number", null: false
    t.date "starts_on", null: false
    t.date "ends_on"
    t.string "status", default: "draft", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id", "number"], name: "index_supply_contracts_on_plant_id_and_number", unique: true
    t.index ["plant_id"], name: "index_supply_contracts_on_plant_id"
    t.check_constraint "(status::text = ANY (ARRAY['draft'::character varying::text, 'active'::character varying::text, 'ended'::character varying::text, 'cancelled'::character varying::text])) AND (status::text <> 'ended'::text OR ends_on IS NOT NULL)", name: "contract_status"
    t.check_constraint "ends_on IS NULL OR ends_on >= starts_on", name: "contract_date_order"
    t.check_constraint "length(TRIM(BOTH FROM number)) > 0", name: "contract_number_present"
    t.exclusion_constraint "connection_id WITH =, daterange(starts_on, ends_on, '[]'::text) WITH &&", where: "(status)::text = ANY (ARRAY[('active'::character varying)::text, ('ended'::character varying)::text])", using: :gist, name: "no_overlapping_supply_contracts"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "administrator", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.check_constraint "email_address::text = lower(TRIM(BOTH FROM email_address)) AND length(email_address::text) > 0", name: "normalized_email"
  end

  add_foreign_key "audit_events", "plants"
  add_foreign_key "audit_events", "users"
  add_foreign_key "connections", "plants"
  add_foreign_key "connections", "route_sections", column: ["route_section_id", "plant_id"], primary_key: ["id", "plant_id"]
  add_foreign_key "customer_memberships", "customers"
  add_foreign_key "customer_memberships", "plants"
  add_foreign_key "customers", "operators"
  add_foreign_key "heat_meters", "connections"
  add_foreign_key "meter_readings", "heat_meters"
  add_foreign_key "meter_readings", "meter_readings", column: ["supersedes_id", "heat_meter_id"], primary_key: ["id", "heat_meter_id"]
  add_foreign_key "meter_readings", "users", column: "recorded_by_id"
  add_foreign_key "plant_permissions", "plants"
  add_foreign_key "plant_permissions", "users"
  add_foreign_key "plants", "operators"
  add_foreign_key "route_sections", "plants"
  add_foreign_key "sessions", "users"
  add_foreign_key "supply_contracts", "connections", column: ["connection_id", "plant_id"], primary_key: ["id", "plant_id"]
  add_foreign_key "supply_contracts", "customer_memberships", column: ["customer_membership_id", "plant_id"], primary_key: ["id", "plant_id"]
  add_foreign_key "supply_contracts", "plants"
end
