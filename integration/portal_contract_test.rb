# Explicit synthetic-only contract probe, deliberately no production transport code.
require_relative "../config/environment"
require "minitest/autorun"
require "net/http"
require "openssl"
require "json"

class PortalContractTest < ActiveSupport::TestCase
  def request(method, suffix, body = nil, key: nil)
    uri = URI("https://localhost/api/index.php/v1/nahwaerme/snapshots#{suffix}")
    http = Net::HTTP.new(uri.host, 443, nil)
    http.use_ssl = true
    http.ca_file = "/fixture/tls/cert.pem"
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.open_timeout = 5
    http.read_timeout = 10
    req = Net::HTTP.const_get(method).new(uri)
    req["Authorization"] = "Bearer #{@token}"
    req["Accept"] = "application/vnd.api+json"
    req["Content-Type"] = "application/vnd.api+json"
    req["Idempotency-Key"] = key if key
    req.body = body unless body.nil?
    http.request(req)
  end

  test "actual Joomla prepares commits replays and rejects stale or changed bytes" do
    assert_equal "1", ENV.fetch("NWB_SYNTHETIC_PORTAL_TEST")
    @token = JSON.parse(File.read("/fixture/api-test-credentials.json")).first.fetch("token")
    batch = SecureRandom.uuid
    customer = SecureRandom.uuid
    payload = { data: { type: "nahwaerme-snapshots", id: batch, attributes: {
      contract_version: "1.0", mode: "full",
      source_id: "11111111-1111-4111-8111-111111111111",
      plant_id: "22222222-2222-4222-8222-222222222222",
      customer_id: customer, revision: "1", serving: false, sites: []
    } } }
    bytes = JSON.generate(payload)
    response = request("Post", "", bytes, key: batch)
    assert_equal "201", response.code
    assert_equal "1", JSON.parse(response.body).dig("data", "attributes", "revision")
    assert_equal "200", request("Get", "/#{batch}").code
    assert_equal "200", request("Post", "", bytes, key: batch).code
    assert_equal "409", request("Post", "", bytes + " ", key: batch).code
    committed = request("Post", "/#{batch}/commit", "")
    assert_equal "200", committed.code
    assert_equal "published", JSON.parse(committed.body).dig("data", "attributes", "status")
    assert_equal "200", request("Post", "/#{batch}/commit", "").code
    payload[:data][:id] = SecureRandom.uuid
    assert_equal "409", request("Post", "", JSON.generate(payload), key: payload[:data][:id]).code
    payload[:data][:attributes][:revision] = "2"
    assert_equal "201", request("Post", "", JSON.generate(payload), key: payload[:data][:id]).code
    assert_equal "200", request("Post", "/#{payload[:data][:id]}/commit", "").code
    # A historical receipt must remain historical after the newer full state.
    assert_equal "200", request("Post", "/#{batch}/commit", "").code
  end
end
