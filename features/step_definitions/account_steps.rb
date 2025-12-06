# features/step_definitions/account_steps.rb

When("I visit the user account page") do
  visit edit_account_path
end

When("I update my name to {string} {string}") do |first_name, last_name|
  fill_in "First name", with: first_name
  fill_in "Last name", with: last_name
end

When("I save my account changes") do
  click_button "Save changes"
end

Then("I should see {string} on the dashboard") do |text|
  visit dashboard_path
  expect(page).to have_content(text)
end

When("I delete my account") do
  click_button "Delete my account"
end

# Profile picture steps

When("I upload a profile picture") do
  image_path = Rails.root.join("spec/fixtures/files/test_jpg_image.jpg")
  attach_file("profile_picture_file", image_path)
end

Then("I should see my profile picture") do
  # After saving, we are on the dashboard, so go back to the account page
  visit edit_account_path
  expect(page).to have_css("img[alt='Profile picture']")
end

When("I remove my profile picture") do
  check "Remove current profile picture"
end

Then("I should not see any profile picture") do
  # Same: make sure we check on the account page
  visit edit_account_path
  expect(page).to have_content("No profile picture set.")
end
