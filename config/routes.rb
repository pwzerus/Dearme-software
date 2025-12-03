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

  # we don't have :new for /posts
  resources :posts, only: [ :create, :show, :edit, :update, :destroy, :index ]

  # Page to Manage sharing of a user's feed
  get "/feed_share_manager",
      to: "feed_share#index",
      as: :feed_share_manager

  # URL to enable sharing (which other users can visit to access
  # a particular user's feed).
  #
  # I would have liked this to be a POST request but apparently a link that
  # is typable/pastable in a browser's address bar is always a GET request
  get "/share_user_feed",
       to: "feed_share#share_user_feed",
       as: :share_user_feed

  # Index page to view all feeds that are shared with a given
  # user (i.e. all the feeds of other users that the logged in
  # user can view)
  get "/shared_user_feeds",
      to: "feed_share#shared_user_feeds",
      as: :shared_user_feeds

  get "/shared_user_feed/:user_id",
      to: "feed_share#shared_user_feed",
      as: :shared_user_feed
end
