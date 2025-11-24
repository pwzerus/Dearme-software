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
