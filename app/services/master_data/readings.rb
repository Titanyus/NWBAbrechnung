module MasterData
  class Readings
    def self.record!(meter:, attributes:, user:, supersedes: nil, boundary_event: false)
      meter.with_lock do
        if supersedes
          supersedes.lock!
          raise ActiveRecord::RecordNotFound unless supersedes.heat_meter_id == meter.id && supersedes.superseded_at.nil?
          supersedes.update_columns(superseded_at: Time.current)
        end
        reading = meter.meter_readings.create!(attributes.merge(recorded_by: user, recorded_at: Time.current, supersedes: supersedes, boundary_event: boundary_event))
        Change.audit!(reading, user: user)
        reading
      end
    end
  end
end
