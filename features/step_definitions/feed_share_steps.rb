SHARE_FEED_LINK_TEXT = "SHARE FEED LINK"

Then('I should see my feed share link') do
  expect(page).to have_link(SHARE_FEED_LINK_TEXT)

  href = find_link(SHARE_FEED_LINK_TEXT)[:href]

  url_encoded_token = CGI.escape(@current_user.feed_share_token.token)
  regex_safe_token = Regexp.escape(url_encoded_token)

  # ? means something special in regex so we need to escape it
  # by preceeding with \
  expect(href).to match(
          %r{/share_user_feed\?token=#{regex_safe_token}}
          )
end

Then('I should see the feed share link validity time') do
  expect(page).to have_content(
          "Link valid till: #{@current_user.feed_share_token.expires_at}")
end

When('I visit the feed share manager page') do
  visit feed_share_manager_path
end
