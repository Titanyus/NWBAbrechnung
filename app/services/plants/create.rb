module Plants
  class Create
    def self.call(user:, attributes:)
      raise ActiveRecord::RecordNotFound unless user.active? && user.administrator?

      Plant.transaction do
        plant = Operator.sole.plants.create!(attributes)
        user.plant_permissions.create!(plant: plant)
        AuditEvent.create!(user: user, plant: plant, action: "plant.created", occurred_at: Time.current)
        plant
      end
    end
  end
end
