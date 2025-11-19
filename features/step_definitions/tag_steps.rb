Given("I do not already have a tag named {string}") do |title|
  Tag.where(creator: @user, title: title).destroy_all
end

Given("I already have a tag named {string}") do |title|
  raise "No current user – use 'Given I am logged in' first" unless @current_user
  Tag.where(creator: @current_user, title: title).first_or_create!
end

When("I create a new tag named {string}") do |title|
  visit tags_path

  # Open the <details> "Create Tag" section if needed
  click_on "Create Tag"

  fill_in "New tag name", with: title
  click_button "Create Tag"
end

When("I attempt to create a new tag with no name") do
  visit tags_path

  # Open the <details> "Create Tag" section if needed
  click_on "Create Tag"

  fill_in "New tag name", with: ""
  click_button "Create Tag"
end

Then("I should see {string} in my list of tags") do |title|
  visit tags_path
  expect(page).to have_content(title)
end

Then("I should see an error that the tag name cannot be blank") do
  expect(page).to have_content("Title can't be blank")
end

Then("the tag should not be created") do
  raise "No current user – use 'Given I am logged in' first" unless @current_user
  # For the blank-name scenario we expect zero tags for this user
  expect(Tag.where(creator: @current_user).count).to eq(0)
end

Then("I should see an error that the tag name has already been taken") do
  expect(page).to have_content("Title has already been taken")
end

Then("the tag should not be duplicated") do
  raise "No current user – use 'Given I am logged in' first" unless @current_user
  titles = Tag.where(creator: @current_user).pluck(:title)
  # Ensure no title appears more than once
  expect(titles.tally.values.max).to eq(1)
end