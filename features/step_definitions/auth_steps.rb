TEST_USER_EMAIL = "test-user@example.com"
TEST_USER_FIRST_NAME = "Test"
TEST_USER_LAST_NAME = "User"

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

Given("I am signed in with Google") do
  step "a valid Google OAuth response"
  visit login_path
  # login/new.html.erb uses a button_to with this text
  click_button "Continue with Google"
  @current_user = User.find_by(email: "test-user@example.com")
end

When("I visit the login page") do
  visit login_path
end

Then("I should be on the login page") do
  expect(page).to have_current_path(login_path, ignore_query: true)
end

Then("I should be on the dashboard page") do
  expect(page).to have_current_path(dashboard_path, ignore_query: true)
end
