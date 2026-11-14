module MasterData
  class Change
    def self.audit!(record, user:, plant: record.plant, action: nil)
      return unless record.saved_changes?

      AuditEvent.create!(user: user, plant: plant, action: action || "#{record.model_name.singular}.saved", occurred_at: Time.current,
        subject_type: record.class.name, subject_id: record.id, changeset: record.saved_changes.except("created_at", "updated_at"))
    end

    def self.save!(record, attributes:, user:)
      record.class.transaction(requires_new: true) do
        record.lock! if record.persisted?
        record.update!(attributes)
        audit!(record, user: user)
      end
      record
    end
  end
end
