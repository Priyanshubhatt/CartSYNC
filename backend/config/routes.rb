Rails.application.routes.draw do
  # GraphQL endpoint
  post "/graphql", to: "graphql#execute"
  
  # GraphQL subscription endpoint
  mount ActionCable.server => '/cable'
  
  # Health check
  get "/health", to: "health#show"
  
  # Devise routes
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
end
