Given("I do not already have a tag named {string}") do |title|
  Tag.where(creator: @user, title: title).destroy_all
end

Given("I already have a tag named {string}") do |title|
  raise "No current user – use 'Given I am logged in' first" unless @current_user
  Tag.where(creator: @current_user, title: title).first_or_create!
end

Given("another user already has a tag named {string}") do |title|
  # Create a different user directly in the DB; no login change
  other_user = User.create!(
    email: "other_user_#{SecureRandom.hex(4)}@example.com",
    first_name: "Other",
    last_name: "User"
  )

  Tag.where(creator: other_user, title: title).first_or_create!
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

When("I rename the tag {string} to {string}") do |old_name, new_name|
  visit tags_path

  # Find the <li> corresponding to this tag
  within(:xpath, "//li[.//strong[text()='#{old_name}']]") do
    # Open the inline edit panel
    find("summary", text: "Edit").click

    # Fill in the new title and save
    fill_in "New title for #{old_name}", with: new_name
    click_button "Save"
  end
end

When("I rename the tag {string} to an empty name") do |old_name|
  visit tags_path

  within(:xpath, "//li[.//strong[text()='#{old_name}']]") do
    find("summary", text: "Edit").click
    fill_in "New title for #{old_name}", with: ""
    click_button "Save"
  end
end

When("I visit the tags page") do
  visit tags_path
end

When("I delete the tag {string}") do |title|
  visit tags_path

  # Find the <li> that contains this tag name and click its Delete button
  within(:xpath, "//li[.//strong[text()='#{title}']]") do
    click_button "Delete"
  end
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

Then("I should not see {string} in my list of tags") do |title|
  visit tags_path
  expect(page).not_to have_content(title)
end

Then("I should still have a tag named {string}") do |title|
  # Check in the DB...
  raise "No current user – use 'Given I am logged in' first" unless @current_user
  expect(Tag.where(creator: @current_user, title: title)).to exist

  # ...and on the page
  visit tags_path
  expect(page).to have_content(title)
end