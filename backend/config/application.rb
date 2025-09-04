require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module CartSync
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
    
    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
    
    # Redis configuration
    config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] || "redis://localhost:6379/0" }
    
    # ActionCable configuration
    config.action_cable.mount_path = '/cable'
    config.action_cable.allowed_request_origins = ['http://localhost:3000', 'http://localhost:3001']
  end
end
