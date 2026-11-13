Rails.application.configure do
  config.cache_store = :memory_store
  config.log_level = :info
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.public_file_server.enabled = true
  config.hosts = ENV.fetch("RAILS_ALLOWED_HOSTS", "localhost,127.0.0.1").split(",").map(&:strip).reject(&:empty?)
  config.active_support.deprecation = :log
end
