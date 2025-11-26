def get_test_file_path_from_name(filename)
  Rails.root.join("spec", "fixtures", "files", filename)
end

def validate_page_shows_media_file(filename, file_type)
  case file_type
  when MediaFile::Type::IMAGE
    # *= means "contains"
    expect(page).to have_css("img" +
                             "[src*='#{filename}']" +
                             "[alt='#{filename}']")
  else
    raise "Trying to see unknown file type"
  end
end

Given('a post exists with:') do |table|
  # Converts the table into a hash with first column as keys
  # and second column elements as corresponding values
  attrs = table.rows_hash

  creator_email = attrs["creator_email"] ? attrs["creator_email"] :
                                           TEST_USER_EMAIL
  creator = User.find_by!(email: creator_email)

  p = Post.create!(
          title: attrs["title"] ? attrs["title"] : "Some default title",
          creator: creator
          )

  # A string consisting of comma separated file names
  images_str = attrs["images"]
  if images_str.present?
    # arr.map(&:strip) is equivalent to
    # arr.map { |elem| elem.strip }
    images_str.split(",").map(&:strip).each do |filename|
      mf = p.media_files.new(file_type: MediaFile::Type::IMAGE)

      filepath = get_test_file_path_from_name(filename)
      puts filepath
      mf.file.attach(
              io: File.open(filepath),
              filename: filename,
              content_type: Marcel::MimeType.for(filepath)
              )
      mf.save!
    end
  end
end

Then('I should see a new post created with defaults') do
  expect(page).to have_content(@current_user.email)

  # default status
  expect(page).to have_content("Archived")

  # check that there is some default title
  # (I've left out the time intentionally,
  # just checking for date)
  expect(page).to have_content(
          "Post #{Time.now.strftime("%Y-%m-%d")}"
          )
end

Given('I visit the view post page for {string}') do |title|
  p = Post.find_by!(title: title)
  visit post_path(p)
end

Given('I visit the edit post page for {string}') do |title|
  p = Post.find_by!(title: title)
  visit edit_post_path(p)
end

Then('I should see images attached to {string} post') do |title|
  p = Post.find_by!(title: title)
  p.media_files.where(file_type: MediaFile::Type::IMAGE).each do |mf|
    validate_page_shows_media_file(mf.file.filename,
                                   MediaFile::Type::IMAGE)
 end
end

Then('I should see the {string} image') do |filename|
  puts page.html
  validate_page_shows_media_file(filename, MediaFile::Type::IMAGE)
end

Then('I should be on the edit post page for {string}') do |title|
  p = Post.find_by!(title: title)
  expect(page).to have_current_path(edit_post_path(p))
end

Then('I should be on the view post page for {string}') do |title|
  p = Post.find_by!(title: title)
  expect(page).to have_current_path(post_path(p))
end

When('I edit post title to {string}') do |new_title|
  fill_in "Title", with: new_title
end

When('I edit post description to {string}') do |new_description|
  fill_in "Description", with: new_description
end

When('I attach the following media files to the post:') do |table|
  filenames = table.raw.flatten
  selector_id = "added_files"
  attach_file "added_files",
              filenames.map { |nm| get_test_file_path_from_name(nm) }
end
