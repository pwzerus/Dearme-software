Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get    "/login",                   to: "login#new",                 as: :login
  post   "/auth/google_oauth2",     to: redirect("/auth/google_oauth2") # button_to safety
  get    "/auth/:provider/callback", to: "login#omniauth_callback"
  get    "/auth/failure",           to: "login#failure",             as: :auth_failure
  delete "/logout",                  to: "login#destroy",             as: :logout

  resources :tags
  
  get "/dashboard", to: "dashboard#show", as: :dashboard
  root to: redirect("/dashboard")

  resources :posts, only: [ :create, :show, :edit, :update, :destroy ]
end
