Rails.application.routes.draw do
  # Health check
  get "/health", to: proc { [ 200, {}, [ "OK" ] ] }

  # API Documentation
  get "/api", to: redirect("/api/docs")
  get "/api/docs", to: "api/docs#index"

  # API v1
  namespace :api do
    namespace :v1 do
      resources :events, only: [ :create ]
    end
  end

  # Fallback for unversioned API calls
  namespace :api do
    post "/events", to: "v1/events#create"
  end
end
