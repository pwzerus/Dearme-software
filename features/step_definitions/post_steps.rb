Given('a post exists with:') do |table|
  # Converts the table into a hash with first column as keys
  # and second column elements as corresponding values
  attrs = table.rows_hash

  creator_email = attrs["creator_email"] ? attrs["creator_email"] :
                                           TEST_USER_EMAIL
  creator = User.find_by!(email: creator_email)

  Post.create!(
          title: attrs["title"] ? attrs["title"] : "Some default title",
          creator: creator
          )
end

Then('I should see a new post created with defaults') do
  expect(page).to have_content(@current_user.email)

  # default status
  expect(page).to have_content("Archived")

  # check that there is some default title
  # (I've left out the time intentionally,
  #just checking for date)
  expect(page).to have_content(
          "Post #{Time.now.strftime("%Y-%m-%d")}"
          )
end

Given('I visit the view post page for {string}') do |title|
  p = Post.find_by!(title: title)
  visit post_path(p)
end
