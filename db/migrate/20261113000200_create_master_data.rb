class CreateMasterData < ActiveRecord::Migration[8.1]
  def change
    enable_extension "btree_gist"
    create_table :customers, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :operator, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.text :address, null: false
      t.string :phone
      t.string :email
      t.text :notes
      t.timestamps
    end
    add_check_constraint :customers, "length(trim(coalesce(company_name, ''))) > 0 OR (length(trim(coalesce(first_name, ''))) > 0 AND length(trim(coalesce(last_name, ''))) > 0)", name: "customer_identity_present"
    add_check_constraint :customers, "length(trim(address)) > 0", name: "customer_address_present"

    create_table :customer_memberships, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :customer, type: :uuid, null: false, foreign_key: true
      t.references :plant, type: :uuid, null: false, foreign_key: true
      t.string :customer_number
      t.string :payment_method, null: false, default: "bank_transfer"
      t.boolean :direct_debit_agreement, null: false, default: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :customer_memberships, [ :customer_id, :plant_id ], unique: true
    add_index :customer_memberships, [ :id, :plant_id ], unique: true
    add_index :customer_memberships, [ :plant_id, :customer_number ], unique: true, where: "customer_number IS NOT NULL"
    add_check_constraint :customer_memberships, "payment_method IN ('bank_transfer','direct_debit','cash','other')", name: "membership_payment_method"

    create_table :route_sections, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :plant, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :code
      t.text :description
      t.timestamps
    end
    add_index :route_sections, [ :id, :plant_id ], unique: true
    add_check_constraint :route_sections, "length(trim(name)) > 0", name: "route_name_present"

    create_table :connections, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :plant, type: :uuid, null: false, foreign_key: true
      t.uuid :route_section_id
      t.string :number, null: false
      t.text :address, null: false
      t.date :commissioned_on
      t.string :technical_status, null: false, default: "active"
      t.text :notes
      t.timestamps
    end
    add_index :connections, [ :id, :plant_id ], unique: true
    add_index :connections, [ :plant_id, :number ], unique: true
    add_foreign_key :connections, :route_sections, column: [ :route_section_id, :plant_id ], primary_key: [ :id, :plant_id ]
    add_check_constraint :connections, "length(trim(number)) > 0 AND length(trim(address)) > 0", name: "connection_required_fields"
    add_check_constraint :connections, "technical_status IN ('planned','active','inactive')", name: "connection_status"

    create_table :supply_contracts, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :plant, type: :uuid, null: false, foreign_key: true
      t.uuid :customer_membership_id, null: false
      t.uuid :connection_id, null: false
      t.string :number, null: false
      t.date :starts_on, null: false
      t.date :ends_on
      t.string :status, null: false, default: "draft"
      t.text :notes
      t.timestamps
    end
    add_foreign_key :supply_contracts, :customer_memberships, column: [ :customer_membership_id, :plant_id ], primary_key: [ :id, :plant_id ]
    add_foreign_key :supply_contracts, :connections, column: [ :connection_id, :plant_id ], primary_key: [ :id, :plant_id ]
    add_index :supply_contracts, [ :plant_id, :number ], unique: true
    add_check_constraint :supply_contracts, "ends_on IS NULL OR ends_on >= starts_on", name: "contract_date_order"
    add_check_constraint :supply_contracts, "status IN ('draft','active','ended','cancelled') AND (status <> 'ended' OR ends_on IS NOT NULL)", name: "contract_status"
    add_check_constraint :supply_contracts, "length(trim(number)) > 0", name: "contract_number_present"
    add_exclusion_constraint :supply_contracts, "connection_id WITH =, daterange(starts_on, ends_on, '[]') WITH &&", where: "status IN ('active', 'ended')", using: :gist, name: "no_overlapping_supply_contracts"

    create_table :heat_meters, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :connection, type: :uuid, null: false, foreign_key: true
      t.string :serial_number, null: false
      t.date :installed_on, null: false
      t.date :removed_on
      t.string :unit, null: false, default: "kWh"
      t.text :notes
      t.timestamps
    end
    add_check_constraint :heat_meters, "removed_on IS NULL OR removed_on > installed_on", name: "meter_date_order"
    add_check_constraint :heat_meters, "unit IN ('kWh', 'MWh') AND length(trim(serial_number)) > 0", name: "meter_required_fields"
    add_exclusion_constraint :heat_meters, "connection_id WITH =, daterange(installed_on, removed_on, '[)') WITH &&", using: :gist, name: "no_overlapping_heat_meters"

    create_table :meter_readings, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :heat_meter, type: :uuid, null: false, foreign_key: true
      t.date :read_on, null: false
      t.decimal :value, precision: 20, scale: 6, null: false
      t.string :kind, null: false
      t.text :comment
      t.references :recorded_by, null: false, foreign_key: { to_table: :users }
      t.datetime :recorded_at, null: false
      t.uuid :supersedes_id
      t.datetime :superseded_at
      t.timestamps
    end
    add_index :meter_readings, [ :id, :heat_meter_id ], unique: true
    add_index :meter_readings, [ :heat_meter_id, :read_on ], unique: true, where: "superseded_at IS NULL", name: "one_effective_reading_per_day"
    add_index :meter_readings, :supersedes_id, unique: true
    add_foreign_key :meter_readings, :meter_readings, column: [ :supersedes_id, :heat_meter_id ], primary_key: [ :id, :heat_meter_id ]
    add_check_constraint :meter_readings, "value >= 0", name: "reading_nonnegative"
    add_check_constraint :meter_readings, "kind IN ('annual','interim','installation','removal','correction')", name: "reading_kind"
    add_check_constraint :meter_readings, "kind <> 'correction' OR length(trim(coalesce(comment, ''))) > 0", name: "correction_requires_reason"

    add_column :audit_events, :subject_type, :string
    add_column :audit_events, :subject_id, :uuid
    add_column :audit_events, :changeset, :jsonb, null: false, default: {}
  end
end
