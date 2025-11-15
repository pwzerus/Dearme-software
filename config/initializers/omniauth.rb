# config/initializers/omniauth.rb

client_id     = ENV["GOOGLE_CLIENT_ID"]
client_secret = ENV["GOOGLE_CLIENT_SECRET"]

if Rails.env.development? && (client_id.nil? || client_secret.nil?)
  Rails.logger.warn "[omniauth] GOOGLE_CLIENT_ID/SECRET missing. " \
                    "Create .env and set them."
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           client_id,
           client_secret,
           {
             scope:  "email,profile",
             prompt: "select_account"
           }
end

OmniAuth.config.allowed_request_methods = [ :post ]
