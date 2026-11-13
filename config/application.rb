require_relative "boot"
require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"
Bundler.require(*Rails.groups)

module NwbVerwaltung
  class Application < Rails::Application
    config.load_defaults 8.1
    config.logger = ActiveSupport::Logger.new($stdout) if ENV["RAILS_LOG_TO_STDOUT"] == "1"
    config.log_level = :info
    config.filter_parameters += %i[customer customer_membership route_section connection heat_meter meter_reading supply_contract q closing_value initial_value email_address]
    config.filter_parameters += %i[cursor]
    config.time_zone = "Europe/Berlin"
    config.i18n.default_locale = :de
    config.action_dispatch.cookies_same_site_protection = :lax
    config.filter_parameters += [ :password, :password_confirmation, :token, :secret, :authorization ]
  end
end
