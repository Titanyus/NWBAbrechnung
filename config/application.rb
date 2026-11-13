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
    config.time_zone = "Europe/Berlin"
    config.i18n.default_locale = :de
    config.action_dispatch.cookies_same_site_protection = :lax
    config.filter_parameters += [ :password, :password_confirmation, :token, :secret, :authorization ]
  end
end
