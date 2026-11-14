module Contracts
  class Draft
    include ActiveModel::Model

    attr_reader :plant, :user, :new_customer, :new_membership, :new_connection, :new_meter, :contract,
      :selected_membership, :selected_connection, :customer_mode, :connection_mode, :meter_mode, :initial_value
    validates :customer_mode, :connection_mode, inclusion: { in: %w[existing new] }
    validates :meter_mode, inclusion: { in: %w[none new] }
    validate :validate_records

    def initialize(plant:, user:, selection: {}, customer: {}, membership: {}, connection: {}, meter: {}, contract: {}, initial_value: nil)
      raise ActiveRecord::RecordNotFound unless user.active? && user.plants.exists?(plant.id)
      @plant, @user = plant, user
      @customer_mode = selection.fetch(:customer_mode, "existing")
      @connection_mode = selection.fetch(:connection_mode, "existing")
      @meter_mode = selection.fetch(:meter_mode, "none")
      @initial_value = initial_value
      @new_customer = plant.operator.customers.new(customer)
      @new_membership = plant.customer_memberships.new(membership.merge(customer: new_customer))
      @new_connection = plant.connections.new(connection.except(:route_section_id))
      if connection_mode == "new" && connection[:route_section_id].present?
        new_connection.route_section = plant.route_sections.find(connection[:route_section_id])
      end
      @new_meter = HeatMeter.new(meter)
      @contract = plant.supply_contracts.new(contract)
      if customer_mode == "existing" && selection[:customer_membership_id].present?
        @selected_membership = plant.customer_memberships.includes(:customer).find(selection[:customer_membership_id])
      end
      if connection_mode == "existing" && selection[:connection_id].present?
        @selected_connection = plant.connections.find(selection[:connection_id])
      end
      @contract.customer_membership = customer_mode == "new" ? new_membership : selected_membership
      @contract.connection = connection_mode == "new" ? new_connection : selected_connection
      new_meter.connection = @contract.connection
    end

    def save
      plant.with_lock do
        raise ActiveRecord::RecordNotFound unless user.active? && user.plants.exists?(plant.id)
        return false unless valid?
        SupplyContract.transaction(requires_new: true) do
          if customer_mode == "new"
            new_customer.save!
            MasterData::Change.audit!(new_customer, user: user, plant: plant)
            new_membership.save!
            MasterData::Change.audit!(new_membership, user: user)
          end
          MasterData::Change.save!(new_connection, attributes: {}, user: user) if connection_mode == "new"
          contract.connection.with_lock(requires_new: true) do
            if meter_mode == "new"
              if current_meter
                new_meter.errors.add(:base, "Ein Zähler ist bereits eingebaut. Einen Zählerwechsel bitte separat durchführen.")
                raise ActiveRecord::RecordInvalid.new(new_meter)
              end
              MasterData::Meters.install!(connection: contract.connection, attributes: new_meter.attributes.slice("serial_number", "installed_on", "unit", "notes"), initial_value: initial_value, user: user)
            end
            contract.customer_membership = new_membership if customer_mode == "new"
            contract.connection = new_connection if connection_mode == "new"
            MasterData::Change.save!(contract, attributes: {}, user: user)
          end
        end
      end
      true
    rescue ActiveRecord::RecordInvalid => error
      errors.add(:base, error.record.errors.full_messages.join("; "))
      false
    rescue ActiveRecord::StatementInvalid => error
      raise unless [ PG::ExclusionViolation, PG::UniqueViolation, PG::CheckViolation ].any? { |type| error.cause.is_a?(type) }
      errors.add(:base, "Die Angaben kollidieren mit einem vorhandenen Datensatz. Bitte Nummern und Zeiträume prüfen.")
      false
    end

    def current_meter
      return unless contract.connection&.persisted?
      contract.connection.heat_meters.where("installed_on <= ? AND (removed_on IS NULL OR removed_on > ?)", Date.current, Date.current).order(installed_on: :desc).first
    end

    private

    def validate_records
      records = [ contract ]
      records.concat([ new_customer, new_membership ]) if customer_mode == "new"
      records << new_connection if connection_mode == "new"
      records << new_meter if meter_mode == "new"
      records.each do |record|
        next if record.valid?
        record.errors.full_messages.each { |message| errors.add(:base, "#{record.model_name.human}: #{message}") }
      end
    end
  end
end
