Given("a valid Google OAuth response") do
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid: "1234567890",
    info: {
      email: "test-user@example.com",
      first_name: "Test",
      last_name: "User"
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
end

When("I visit the login page") do
  visit login_path
end

When("I visit the dashboard page") do
  visit dashboard_path
end

When("I click {string}") do |text|
  # Works for both links and buttons
  click_link_or_button text
end

Then("I should be on the login page") do
  expect(page).to have_current_path(login_path, ignore_query: true)
end

Then("I should be on the dashboard page") do
  expect(page).to have_current_path(dashboard_path, ignore_query: true)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end
