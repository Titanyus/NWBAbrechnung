require "digest"

class ContractBrowser
  PAGE_SIZE = 30
  FILTER_KEYS = %w[q customer_number connection_number route_section_id status starts_after ends_before sort direction].freeze
  SORTS = {
    "number" => [ "supply_contracts.number" ],
    "customer" => [ "customers.company_name", "customers.last_name", "customers.first_name" ],
    "connection" => [ "connections.number" ], "route" => [ "route_sections.name" ],
    "status" => [ "supply_contracts.status" ], "starts_on" => [ "supply_contracts.starts_on" ]
  }.freeze
  class InvalidCursor < StandardError; end
  attr_reader :filters, :sort, :direction, :offset, :next_cursor, :error

  def initialize(plant:, user:, parameters:)
    raise ActiveRecord::RecordNotFound unless user.active? && user.plants.exists?(plant.id)
    @plant, @user = plant, user
    @filters = FILTER_KEYS.filter_map do |key|
      value = parameters[key]
      [ key, value.strip.first(200) ] if value.is_a?(String) && value.present?
    end.to_h
    @sort = SORTS.key?(filters["sort"]) ? filters["sort"] : "customer"
    @direction = filters["direction"] == "desc" ? "desc" : "asc"
    @filters["sort"], @filters["direction"] = @sort, @direction
  end

  def scope
    @scope ||= begin
      result = @plant.supply_contracts.joins(customer_membership: :customer).left_joins(connection: :route_section)
      if filters["q"].present?
        result = result.where("supply_contracts.number ILIKE :q OR customers.company_name ILIKE :q OR concat_ws(' ', customers.first_name, customers.last_name) ILIKE :q OR customers.address ILIKE :q OR connections.address ILIKE :q OR connections.number ILIKE :q OR customer_memberships.customer_number ILIKE :q", q: term(filters["q"]))
      end
      result = result.where("customer_memberships.customer_number ILIKE ?", term(filters["customer_number"])) if filters["customer_number"]
      result = result.where("connections.number ILIKE ?", term(filters["connection_number"])) if filters["connection_number"]
      result = result.where(connections: { route_section_id: @plant.route_sections.find(filters["route_section_id"]).id }) if filters["route_section_id"]
      result = result.where(status: filters["status"]) if filters["status"]
      begin
        result = result.where("supply_contracts.starts_on >= ?", Date.iso8601(filters["starts_after"])) if filters["starts_after"]
        result = result.where("supply_contracts.starts_on <= ?", Date.iso8601(filters["ends_before"])) if filters["ends_before"]
      rescue Date::Error
        @error = "Bitte gültige Datumsgrenzen eingeben."
        result = result.none
      end
      result
    end
  end

  def count
    scope.count
  end

  def batch(cursor: nil)
    @offset = 0
    if cursor.present?
      raise InvalidCursor unless cursor.is_a?(String)
      payload = verifier.verified(cursor, purpose: "contract-pages")
      raise InvalidCursor unless payload.is_a?(Hash) && payload["plant"] == @plant.id && payload["user"] == @user.id && payload["query"] == fingerprint
      @offset = payload["offset"]
      raise InvalidCursor unless @offset.is_a?(Integer) && @offset >= 0 && (@offset % PAGE_SIZE).zero?
    end
    ordered = if sort == "customer"
      name = Arel.sql("COALESCE(NULLIF(btrim(customers.company_name), ''), concat_ws(', ', customers.last_name, customers.first_name))")
      scope.order(direction == "desc" ? name.desc : name.asc)
    else
      scope.order(SORTS.fetch(sort).index_with { direction.to_sym })
    end
    records = ordered.order("supply_contracts.id")
      .includes({ connection: :route_section }, customer_membership: :customer).offset(offset).limit(PAGE_SIZE + 1).to_a
    @next_cursor = if records.length > PAGE_SIZE
      verifier.generate({ "plant" => @plant.id, "user" => @user.id, "query" => fingerprint, "offset" => offset + PAGE_SIZE }, purpose: "contract-pages", expires_in: 12.hours)
    end
    records.first(PAGE_SIZE)
  end

  def fingerprint
    Digest::SHA256.hexdigest(filters.sort.to_h.to_json)
  end

  private

  def term(value)
    "%#{SupplyContract.sanitize_sql_like(value)}%"
  end

  def verifier
    Rails.application.message_verifier("contract-browser-v1")
  end
end
