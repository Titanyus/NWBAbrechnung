module MasterData
  class Meters
    def self.install!(connection:, attributes:, initial_value:, user:)
      connection.with_lock(requires_new: true) do
        meter = connection.heat_meters.create!(attributes)
        Change.audit!(meter, user: user)
        Readings.record!(meter: meter, attributes: { read_on: meter.installed_on, value: initial_value, kind: "installation" }, user: user)
        meter
      end
    end

    def self.retire!(meter:, removed_on:, closing_value:, user:)
      meter.connection.with_lock(requires_new: true) do
        meter.lock!
        raise ActiveRecord::RecordInvalid.new(meter) if meter.removed_on
        existing = meter.meter_readings.effective.find_by(read_on: removed_on)
        if existing
          unless existing.value == BigDecimal(closing_value.to_s)
            meter.errors.add(:base, "Der Schlusswert weicht vom vorhandenen Tageswert ab. Bitte zuerst die Ablesung korrigieren.")
            raise ActiveRecord::RecordInvalid.new(meter)
          end
        else
          Readings.record!(meter: meter, attributes: { read_on: removed_on, value: closing_value, kind: "removal" }, user: user, boundary_event: true)
        end
        Change.save!(meter, attributes: { removed_on: removed_on }, user: user)
      end
    end

    def self.exchange!(meter:, on:, closing_value:, attributes:, initial_value:, user:)
      meter.connection.with_lock(requires_new: true) do
        retire!(meter: meter, removed_on: on, closing_value: closing_value, user: user)
        install!(connection: meter.connection, attributes: attributes.merge(installed_on: on), initial_value: initial_value, user: user)
      end
    end
  end
end
