require "json"
abort "Nur ausdrücklich freigegebene synthetische UI-Prüfung" unless ENV["NWB_SYNTHETIC_UI"] == "1" && (Rails.env.development? || Rails.env.test?)
abort "Synthetischer Betreiber erforderlich" unless Operator.sole.name.start_with?("Synthetische Nahwärme")
plant = Plant.find_by!(name: "Testanlage 01")
user = User.find_by!(email_address: "admin@example.test")
route = plant.route_sections.find_or_create_by!(code: "UX-REVIEW") { |r| r.name = "Beispieltrasse Nord"; r.description = "Ausschließlich synthetische UI-Prüfdaten" }
150.times do |i|
  number = format("UX-%03d", i + 1)
  membership = plant.customer_memberships.find_by(customer_number: number)
  unless membership
    customer = plant.operator.customers.create!(company_name: format("Beispielbetrieb %02d GmbH", i + 1), address: "Beispielstraße #{i + 1}\n00000 Musterort", phone: "0000-TEST", email: "beispiel#{i + 1}@example.test", notes: "Synthetische Daten für den UI-Vergleich")
    membership = plant.customer_memberships.create!(customer: customer, customer_number: number, active: i != 5)
  end
  abort "Vorhandene Kundennummer gehört nicht zur UI-Fixture" unless membership.customer.email == "beispiel#{i + 1}@example.test"
  connection = plant.connections.find_or_create_by!(number: number) { |c| c.route_section = route; c.address = "Beispielstraße #{i + 1}\n00000 Musterort"; c.commissioned_on = Date.new(2025, 1, 1) }
  unless plant.supply_contracts.exists?(number: number)
    MasterData::Change.save!(plant.supply_contracts.new, attributes: { number: number, customer_membership: membership, connection: connection, starts_on: Date.new(2025, 1, 1), status: "active" }, user: user)
  end
  meter = connection.heat_meters.first
  meter ||= MasterData::Meters.install!(connection: connection, attributes: { serial_number: number, installed_on: Date.new(2025, 1, 1), unit: "kWh" }, initial_value: "0.125", user: user)
  if i.zero?
    18.times do |index|
      date = Date.new(2025, 2, 1) >> index
      unless meter.meter_readings.effective.exists?(read_on: date)
        MasterData::Readings.record!(meter: meter, attributes: { read_on: date, value: BigDecimal((index + 1).to_s) * 100 + BigDecimal("0.125"), kind: "interim", comment: "Synthetischer Prüfwert" }, user: user)
      end
    end
  end
end
customer = plant.customer_memberships.find_by!(customer_number: "UX-001").customer
connection = plant.connections.find_by!(number: "UX-001")
meter = connection.heat_meters.first
contract = plant.supply_contracts.find_by!(number: "UX-001")
base = "/plants/#{plant.id}"
puts JSON.generate(plants: "/plants", customers: "#{base}/customers", customer_detail: "#{base}/customers/#{customer.id}", contracts: "#{base}/supply_contracts", contract_detail: "#{base}/supply_contracts/#{contract.id}", connections: "#{base}/connections", meters: "#{base}/heat_meters", readings: "#{base}/heat_meters/#{meter.id}", customer_form: "#{base}/customers/#{customer.id}/edit", plant: base, route_sections: "#{base}/route_sections", contract_form: "#{base}/supply_contracts/#{contract.id}/edit", connection_form: "#{base}/connections/#{connection.id}/edit", meter_form: "#{base}/heat_meters/new", reading_form: "#{base}/heat_meters/#{meter.id}/meter_readings/new", appearance: "/appearance", new_plant: "/plants/new", new_customer: "#{base}/customers/new", new_route: "#{base}/route_sections/new", meter_edit: "#{base}/heat_meters/#{meter.id}/edit", meter_replacement: "#{base}/heat_meters/#{meter.id}/replacement")
