class CreateFoundation < ActiveRecord::Migration[8.1]
  def change
    create_table :operators do |t|
      t.string :name, null: false
      t.integer :singleton_key, null: false, default: 1
      t.uuid :source_id, null: false, default: -> { "gen_random_uuid()" }
      t.timestamps
    end
    add_index :operators, :singleton_key, unique: true
    add_index :operators, :source_id, unique: true
    add_check_constraint :operators, "singleton_key = 1", name: "one_operator"
    add_check_constraint :operators, "length(trim(name)) > 0", name: "operator_name_present"

    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.boolean :administrator, null: false, default: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_check_constraint :users, "email_address = lower(trim(email_address)) AND length(email_address) > 0", name: "normalized_email"

    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, null: false
      t.timestamps
    end
    create_table :plants, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :operator, null: false, foreign_key: true
      t.string :name, null: false
      t.text :address, null: false
      t.text :technical_notes
      t.timestamps
    end
    add_check_constraint :plants, "length(trim(name)) > 0 AND length(trim(address)) > 0", name: "plant_required_fields"
    create_table :plant_permissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plant, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
    add_index :plant_permissions, [ :user_id, :plant_id ], unique: true
    create_table :audit_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plant, type: :uuid, null: false, foreign_key: true
      t.string :action, null: false
      t.datetime :occurred_at, null: false
    end
  end
end
