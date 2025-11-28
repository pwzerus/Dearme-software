Given("the following user exists:") do |table|
  table.hashes.each do |row|
    User.create!(
      email:      row["email"],
      first_name: row["first_name"],
      last_name:  row["last_name"]
    )
  end
end

Given("I am logged in as {string}") do |email|
  user = User.find_by!(email: email)
  # If you already have a login helper step, call it here instead.
  # Example for a simple custom login form:
  visit new_session_path
  fill_in "Email", with: user.email
  click_button "Log in"
end

Given("the following posts exist for {string}:") do |email, table|
  user = User.find_by!(email: email)

  table.hashes.each do |row|
    Post.create!(
      creator: user,
      title:   row["title"]
    )
  end
end

Given("the following tags exist for {string}:") do |email, table|
  user = User.find_by!(email: email)

  table.hashes.each do |row|
    Tag.create!(
      creator: user,
      title:   row["title"]
    )
  end
end

Given('the tag {string} is associated with the post {string}') do |tag_title, post_title|
  tag  = Tag.find_by!(title: tag_title)
  post = Post.find_by!(title: post_title)

  PostTag.find_or_create_by!(post: post, tag: tag)
end

Given('the tag {string} is not associated with the post {string}') do |tag_title, post_title|
  tag  = Tag.find_by!(title: tag_title)
  post = Post.find_by!(title: post_title)

  PostTag.where(post: post, tag: tag).delete_all
end

When('I visit the edit page for the tag {string}') do |tag_title|
  tag = Tag.find_by!(title: tag_title)
  visit edit_tag_path(tag)
end

When('I check the post {string} for this tag') do |post_title|
  # Assumes the edit tag view renders a checkbox per post, labeled with the post title.
  # You will align the form markup to make this work (e.g. using collection_check_boxes).
  check post_title
end

When('I uncheck the post {string} for this tag') do |post_title|
  uncheck post_title
end

When("I submit the tag form") do
  # Adjust this to match your actual submit button text on the tag edit page
  click_button "Update Tag"
end

Then('the post {string} should be tagged with {string}') do |post_title, tag_title|
  post = Post.find_by!(title: post_title)
  tag  = Tag.find_by!(title: tag_title)

  # Either check via database:
  expect(PostTag.exists?(post: post, tag: tag)).to be true

  # Or (optionally) via UI, e.g.:
  # visit post_path(post)
  # expect(page).to have_content(tag_title)
end

Then('the post {string} should not be tagged with {string}') do |post_title, tag_title|
  post = Post.find_by!(title: post_title)
  tag  = Tag.find_by!(title: tag_title)

  expect(PostTag.exists?(post: post, tag: tag)).to be false

  # Or (optionally) via UI as well:
  # visit post_path(post)
  # expect(page).not_to have_content(tag_title)
end

Then('the post {string} should still be tagged with {string}') do |post_title, tag_title|
  post = Post.find_by!(title: post_title)
  tag  = Tag.find_by!(title: tag_title)

  expect(PostTag.exists?(post: post, tag: tag)).to be true
end

Then('the post {string} should still not be tagged with {string}') do |post_title, tag_title|
  post = Post.find_by!(title: post_title)
  tag  = Tag.find_by!(title: tag_title)

  expect(PostTag.exists?(post: post, tag: tag)).to be false
end
