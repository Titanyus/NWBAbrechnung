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

ActiveRecord::Schema[8.1].define(version: 2026_11_13_000100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.uuid "plant_id", null: false
    t.string "action", null: false
    t.datetime "occurred_at", null: false
    t.index ["plant_id"], name: "index_audit_events_on_plant_id"
    t.index ["user_id"], name: "index_audit_events_on_user_id"
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
    t.text "address", null: false
    t.text "technical_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_id"], name: "index_plants_on_operator_id"
    t.check_constraint "length(TRIM(BOTH FROM name)) > 0 AND length(TRIM(BOTH FROM address)) > 0", name: "plant_required_fields"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
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
  add_foreign_key "plant_permissions", "plants"
  add_foreign_key "plant_permissions", "users"
  add_foreign_key "plants", "operators"
  add_foreign_key "sessions", "users"
end
