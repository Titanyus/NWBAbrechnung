class StructureAddresses < ActiveRecord::Migration[8.1]
  TABLES = %i[plants customers connections].freeze

  def up
    TABLES.each do |table|
      rename_column table, :address, :street
      add_column table, :postal_code, :string, limit: 20, null: false, default: "00000"
      add_column table, :city, :string, limit: 200, null: false, default: "Demoort"
      # Explicitly authorized replacement of disposable demo addresses; no guessing/parser.
      execute "UPDATE #{quote_table_name(table)} SET street = 'Demostraße 1'"
      change_column_default table, :postal_code, from: "00000", to: nil
      change_column_default table, :city, from: "Demoort", to: nil
      add_check_constraint table, "length(trim(street)) BETWEEN 1 AND 500 AND length(trim(postal_code)) BETWEEN 1 AND 20 AND length(trim(city)) BETWEEN 1 AND 200 AND position(chr(10) in street || postal_code || city) = 0 AND position(chr(13) in street || postal_code || city) = 0", name: "#{table}_structured_address"
    end
  end

  def down
    TABLES.reverse_each do |table|
      remove_check_constraint table, name: "#{table}_structured_address"
      execute "UPDATE #{quote_table_name(table)} SET street = street || chr(10) || postal_code || ' ' || city"
      remove_column table, :city
      remove_column table, :postal_code
      rename_column table, :street, :address
    end
  end
end
