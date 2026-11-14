# db:prepare can invoke seeds automatically; demos require an explicit opt-in.
if ENV["NWB_LOAD_DEMO"] != "1"
  puts "Keine Demo-Daten ohne NWB_LOAD_DEMO=1."
else
  abort "Demo-Daten nur in development/test erlaubt" unless Rails.env.development? || Rails.env.test?
  size = ENV.fetch("DEMO_SIZE", "small")
  abort "DEMO_SIZE muss small oder large sein" unless %w[small large].include?(size)
  password = ENV.fetch("DEMO_PASSWORD")
  abort "Demo-Passwort mindestens 14 Zeichen" if password.length < 14
  ApplicationRecord.transaction do
    operator = Operator.first_or_create!(name: "Synthetische Nahwärme #{size == 'large' ? 'Region' : 'Dorf'}")
    admin = User.find_or_initialize_by(email_address: "admin@example.test")
    admin.update!(password: password, administrator: true) if admin.new_record?
    clerk = User.find_or_initialize_by(email_address: "verwaltung@example.test")
    clerk.update!(password: password) if clerk.new_record?
    (size == "large" ? 50 : 3).times do |index|
      name = format("Testanlage %02d", index + 1)
      plant = Plant.find_by(name: name)
      plant ||= Plants::Create.call(user: admin, attributes: { name: name, street: "Musterweg #{index + 1}", postal_code: "00000", city: "Testort", technical_notes: "Synthetische Testanlage" })
      PlantPermission.find_or_create_by!(user: clerk, plant: plant) if index.even?
    end
  end
  puts "Synthetische Daten vorbereitet (#{size}); bestehende Konten und Passwörter bleiben erhalten."
end
