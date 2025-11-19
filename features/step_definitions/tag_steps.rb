Given("I do not already have a tag named {string}") do |title|
  Tag.where(creator: @user, title: title).destroy_all
end

When("I create a new tag named {string}") do |title|
  visit tags_path

  # Open the <details> "Create Tag" section if needed
  click_on "Create Tag"

  fill_in "Tag name", with: title
  click_button "Create Tag"
end

When("I attempt to create a new tag with no name") do
  visit tags_path

  # Open the <details> "Create Tag" section if needed
  click_on "Create Tag"

  fill_in "Tag name", with: ""
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
  expect(Tag.where(creator: @user).count).to eq(0)
end
