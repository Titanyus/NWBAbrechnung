require "test_helper"
require_relative "../support/master_data_setup"

class ContractBrowserTest < ActiveSupport::TestCase
  include MasterDataSetup
  setup { master_data }

  def add_contracts(count)
    count.times do |index|
      conn = @plant.connections.create!(number: "B-#{format('%03d', index)}", address: "Beispielweg #{index}", route_section: @route)
      @plant.supply_contracts.create!(number: "B-#{format('%03d', index)}", connection: conn, customer_membership: @membership, starts_on: "2026-01-01", status: index.even? ? "active" : "draft")
    end
  end

  def browser(params = {}, plant: @plant, user: @clerk, **filters)
    ContractBrowser.new(plant: plant, user: user, parameters: params.merge(filters).stringify_keys)
  end

  test "large results are bounded and load completely in successive batches" do
    add_contracts(85)
    query = browser(sort: "number")
    first = query.batch
    assert_equal 30, first.size
    cursor = query.next_cursor
    assert cursor
    second = query.batch(cursor: cursor)
    assert_equal 30, second.size
    third = query.batch(cursor: query.next_cursor)
    assert_equal 25, third.size
    assert_nil query.next_cursor
    assert_equal 85, (first + second + third).map(&:id).uniq.size
    assert_equal 85, query.count
  end

  test "search applies to the whole dataset not just loaded rows" do
    add_contracts(70)
    assert_equal 30, browser(sort: "number").batch.size
    result = browser(q: "B-069").batch
    assert_equal [ "B-069" ], result.map(&:number)
    assert_equal [ "B-069" ], browser(q: "Beispielweg 69").batch.map(&:number)
    assert_equal 35, browser(status: "active").count
    assert_equal 70, browser(route_section_id: @route.id).count
    assert_equal 70, browser(customer_number: "100").count
    assert_equal [ "B-069" ], browser(connection_number: "B-069").batch.map(&:number)
  end

  test "sorting and date filters remain deterministic" do
    add_contracts(3)
    assert_equal %w[B-002 B-001 B-000], browser(sort: "number", direction: "desc").batch.map(&:number)
    assert_equal 0, browser(starts_after: "2027-01-01").count
    assert_equal 0, browser(ends_before: "2025-01-01").count
    query = browser(starts_after: "not-a-date")
    assert_empty query.batch
    assert query.error
  end

  test "cursor is bound to query user plant and signature" do
    add_contracts(31)
    query = browser(sort: "number")
    query.batch
    cursor = query.next_cursor
    assert_raises(ContractBrowser::InvalidCursor) { browser(q: "changed").batch(cursor: cursor) }
    assert_raises(ContractBrowser::InvalidCursor) { browser({ sort: "number" }, user: @admin).batch(cursor: cursor) }
    @clerk.plant_permissions.create!(plant: @other)
    assert_raises(ContractBrowser::InvalidCursor) { browser({ sort: "number" }, plant: @other).batch(cursor: cursor) }
    assert_raises(ContractBrowser::InvalidCursor) { query.batch(cursor: cursor + "tampered") }
    assert_raises(ContractBrowser::InvalidCursor) { query.batch(cursor: [ cursor ]) }
  end

  test "foreign filters and search cannot disclose other plants" do
    add_contracts(2)
    @other.supply_contracts.create!(number: "FOREIGN-ONLY", connection: @foreign_connection, customer_membership: @foreign_membership, starts_on: "2026-01-01", status: "active")
    assert_empty browser(q: "FOREIGN-ONLY").batch
    assert_empty browser(q: "%' OR 1=1 --").batch
    foreign_route = @other.route_sections.create!(name: "Foreign")
    assert_raises(ActiveRecord::RecordNotFound) { browser(route_section_id: foreign_route.id).batch }
    assert_raises(ActiveRecord::RecordNotFound) { browser({}, plant: @other) }
  end

  test "revoked rights are checked again for later pages" do
    add_contracts(31)
    query = browser
    query.batch
    cursor = query.next_cursor
    @clerk.plant_permissions.where(plant: @plant).destroy_all
    assert_raises(ActiveRecord::RecordNotFound) { browser.batch(cursor: cursor) }
  end
end
