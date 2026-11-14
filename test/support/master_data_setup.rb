module MasterDataSetup
  def master_data
    foundation
    @customer = @operator.customers.create!(first_name: "Synthetische", last_name: "Kundin", street: "Musterweg 3", postal_code: "00000", city: "Testort", email: "synthetic@example.test")
    @membership = @plant.customer_memberships.create!(customer: @customer, customer_number: "100")
    @route = @plant.route_sections.create!(name: "Nordtrasse")
    @connection = @plant.connections.create!(number: "A-1", street: "Testweg 1", postal_code: "00000", city: "Testort", route_section: @route)
    @foreign_customer = @operator.customers.create!(company_name: "Fremde Testfirma", street: "Fremder Musterweg", postal_code: "00000", city: "Testort")
    @foreign_membership = @other.customer_memberships.create!(customer: @foreign_customer, customer_number: "100")
    @foreign_connection = @other.connections.create!(number: "A-1", street: "Fremder Anschluss", postal_code: "00000", city: "Testort")
  end

  def install(connection = @connection, date: Date.new(2026, 1, 1), value: "10.125")
    MasterData::Meters.install!(connection: connection, attributes: { serial_number: "SYN-#{connection.number}", installed_on: date, unit: "kWh" }, initial_value: value, user: @admin)
  end

  def contract(connection: @connection, membership: @membership, **attributes)
    @plant.supply_contracts.new({ connection: connection, customer_membership: membership, number: SecureRandom.hex(4), starts_on: Date.new(2026, 1, 1), status: "active" }.merge(attributes))
  end
end
