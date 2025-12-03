TEST_USER_EMAIL = "test-user@example.com"
TEST_USER_FIRST_NAME = "Test"
TEST_USER_LAST_NAME = "User"

GOOGLE_SIGN_IN_BTN_LABEL = "Continue with Google"

Given("a valid Google OAuth response") do
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid: "1234567890",
    info: {
      email: TEST_USER_EMAIL,
      first_name: TEST_USER_FIRST_NAME,
      last_name: TEST_USER_LAST_NAME
    }
  )
end

Given("Google returns an authentication error") do
  OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
end

When("I visit the login page") do
  visit login_path
end

When("I click to sign in with Google") do
  click_link_or_button GOOGLE_SIGN_IN_BTN_LABEL
end

Then('I should see the sign in with Google interactive element') do
  step "I should see \"#{GOOGLE_SIGN_IN_BTN_LABEL}\""
end

Then("I should be on the login page") do
  expect(page).to have_current_path(login_path, ignore_query: true)
end

Then("I should be on the dashboard page") do
  expect(page).to have_current_path(dashboard_path, ignore_query: true)
end
