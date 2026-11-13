Rails.application.configure do
  config.cache_store = :memory_store
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  # Rails integration tests issue requests without browser CSRF tokens.
  # Browser protection remains enabled in development and is checked over HTTP.
  config.action_controller.allow_forgery_protection = false
  config.action_dispatch.show_exceptions = :rescuable
  config.public_file_server.enabled = true
  config.hosts.clear # Only in test: integration test requests use example hostnames
end
