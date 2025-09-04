Rails.application.configure do
  config.action_cable.url = ENV.fetch("ACTION_CABLE_URL", "ws://localhost:3000/cable")
  config.action_cable.allowed_request_origins = [
    /http:\/\/localhost.*/,
    /https:\/\/.*\.herokuapp\.com/,
    /https:\/\/.*\.vercel\.app/
  ]
end
