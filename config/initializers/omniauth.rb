client_id     = ENV["GOOGLE_CLIENT_ID"]
client_secret = ENV["GOOGLE_CLIENT_SECRET"]

if Rails.env.development? && (client_id.nil? || client_secret.nil?)
  Rails.logger.warn "[omniauth] Missing GOOGLE_CLIENT_ID/SECRET. " \
                    "Copy .env.example to .env and paste shared keys."
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, client_id, client_secret, {
    scope:  "email,profile",
    prompt: "select_account"
  }
end

# With omniauth-rails_csrf_protection, POST is preferred for /auth/*
OmniAuth.config.allowed_request_methods = [:post]

# Optional pinning via env to avoid redirect_uri_mismatch across hosts
OmniAuth.config.full_host = ENV["OMNIAUTH_FULL_HOST"] if ENV["OMNIAUTH_FULL_HOST"]
