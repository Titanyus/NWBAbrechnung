module Plants
  class Remove
    class ConfirmationRequired < StandardError; end
    class NotEmpty < StandardError; end

    def self.confirmation_for(plant:, user:)
      verifier.generate(payload(plant, user), purpose: "plant-removal", expires_in: 10.minutes)
    end

    def self.blocked?(plant)
      [ :route_sections, :customer_memberships, :connections, :supply_contracts ].any? { |association| plant.public_send(association).exists? }
    end

    def self.call(plant:, user:, confirmation:)
      plant.with_lock do
        raise ActiveRecord::RecordNotFound unless user.active? && user.administrator? && user.plants.exists?(plant.id)
        verified = confirmation.is_a?(String) ? verifier.verified(confirmation, purpose: "plant-removal") : nil
        raise ConfirmationRequired unless verified == payload(plant, user)
        raise NotEmpty if blocked?(plant)

        plant.update!(deleted_at: Time.current)
        MasterData::Change.audit!(plant, user: user, plant: plant, action: "plant.deleted")
      end
      plant
    end

    def self.payload(plant, user)
      { "plant" => plant.id, "user" => user.id, "updated_at" => plant.updated_at.iso8601(6) }
    end
    private_class_method :payload

    def self.verifier
      Rails.application.message_verifier("plant-removal-v1")
    end
    private_class_method :verifier
  end
end
