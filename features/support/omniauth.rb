require "omniauth"

Before do
  OmniAuth.config.test_mode = true
end

After do
  OmniAuth.config.mock_auth[:google_oauth2] = nil
end
