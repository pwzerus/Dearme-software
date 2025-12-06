When('I expand the feed filters') do
  find("[data-test='feed-filter-toggle']").click
end

When('I select the tag filter {string}') do |tag_title|
  within("form[data-test='feed-filter-form']") do
    check tag_title
  end
end

When('I set the start date filter to {string}') do |date_str|
  within("form[data-test='feed-filter-form']") do
    fill_in "Start date", with: date_str
  end
end

When('I set the end date filter to {string}') do |date_str|
  within("form[data-test='feed-filter-form']") do
    fill_in "End date", with: date_str
  end
end

When('I apply the feed filters') do
  within("form[data-test='feed-filter-form']") do
    click_button "Apply filters"
  end
end

Then('the tag filter {string} should be checked') do |tag_title|
  within("form[data-test='feed-filter-form']") do
    expect(page).to have_checked_field(tag_title)
  end
end
