# @current_view_user may not exist here as we can come here via the
# non logged in user flow (hence the step Given("I am signed in with Google")
# never executes (which sets @current_user)
#
# Hence, explicitly assigning current_user here, and I think based on this
# case, all tests who need current user should do similar instead of depending
# on @current_user which may not be set if we are performing login manually
# without the Given("I am signed in with Google") step

SHARE_FEED_LINK_TEXT = "SHARE FEED LINK"
REVOKE_ACCESS_BTN_LABEL = "Revoke Access"

Then('I should see my feed share link') do
  expect(page).to have_link(SHARE_FEED_LINK_TEXT)

  href = find_link(SHARE_FEED_LINK_TEXT)[:href]

  current_user = User.find_by!(email: TEST_USER_EMAIL)
  url_encoded_token = CGI.escape(current_user.feed_share_token.token)
  regex_safe_token = Regexp.escape(url_encoded_token)

  # ? means something special in regex so we need to escape it
  # by preceeding with \
  expect(href).to match(
          %r{/share_user_feed\?token=#{regex_safe_token}}
          )
end

Then('I should see the feed share link validity time') do
  current_user = User.find_by!(email: TEST_USER_EMAIL)
  validity_time_str =
    "Link valid till: #{current_user.feed_share_token.expires_at}"
  step "I should see \"#{validity_time_str}\""
end

When('I visit the feed share manager page') do
  visit feed_share_manager_path
end

Then('I should be on the feed share manager page') do
  expect(page).to have_current_path(feed_share_manager_path)
end

When('I visit the feed share link of user {string}') do |email|
  u = User.find_by!(email: email)
  visit share_user_feed_path(token: u.feed_share_token.token)
end

Then('I should be on the shared user feeds page') do
  expect(page).to have_current_path(shared_user_feeds_path)
end

Then('I should see the shared feed entry for user {string}') do |email|
  current_user = User.find_by!(email: TEST_USER_EMAIL)
  user = User.find_by!(email: email)
  step "I should see \"#{user.email}\""

  current_user_view_user = UserViewUser.find_by!(
          viewer: current_user,
          viewee: user
          )

  # Expect page to have the time the feed sharing started
  step "I should see \"#{current_user_view_user.updated_at}\""

  # Expect page to have the time at which the feed would expire
  step "I should see \"#{current_user_view_user.expires_at}\""
end

When('I click to view feed share entry of user {string}') do |email|
  user = User.find_by!(email: email)

  # Within the shared feeds index table, find the row corresponding to
  # the user's feed share entry.
  row = find('table tr', text: user.email)
  within(row) do
    click_link_or_button "View"
  end
end

Then('I should be on the shared feed page for user {string}') do |email|
  user = User.find_by!(email: email)
  expect(page).to have_current_path(shared_user_feed_path(user))
end

Given('I have access to the feed of user {string}') do |email|
  # Logged in user always has access to his feed page (i.e. posts index
  # page)
  unless email == TEST_USER_EMAIL
    # For some other user than the test user (i.e. other than logged in)
    # the logged in user has access to his feed if he has accesses the other
    # user's share feed link
    step "I visit the feed share link of user '#{email}'"
  end
end

Given('user {string} has view access to my feed') do |email|
  viewer = User.find_by!(email: email)
  current_user = User.find_by!(email: TEST_USER_EMAIL)

  UserViewUser.create!(
          viewer: viewer,
          viewee: current_user,
          expires_at: Time.current + FeedShareController::FEED_SHARE_TTL
          )
end

When('I visit the feed page for user {string}') do |email|
  if email == TEST_USER_EMAIL
    visit posts_path
  else
    user = User.find_by!(email: email)
    visit shared_user_feed_path(user)
  end
end

When('I click to view post {string} from the feed') do |title|
  li = find('li', text: title)
  li.click_link('View')
end

When('I click to revoke feed access of user {string}') do |email|
  user = User.find_by!(email: email)
  row = find('tr', text: email)
  within(row) do
    click_link_or_button REVOKE_ACCESS_BTN_LABEL
  end
end
