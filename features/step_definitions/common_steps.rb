Given("I am signed in with Google") do
  step "a valid Google OAuth response"
  visit login_path
  # login/new.html.erb uses a button_to with this text
  step "I click to sign in with Google"

  @current_user = User.find_by!(email: TEST_USER_EMAIL)
end

When("I visit the dashboard page") do
  visit dashboard_path
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

When("I click {string}") do |text|
  # Works for both links and buttons
  click_link_or_button text
end
