Rails.application.configure do
  config.action_cable.mount_path = '/cable'
  config.action_cable.disable_request_forgery_protection = true
end
