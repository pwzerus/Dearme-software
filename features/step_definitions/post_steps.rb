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

      filepath = Rails.root.join("spec", "fixtures", "files", filename)
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
  #just checking for date)
  expect(page).to have_content(
          "Post #{Time.now.strftime("%Y-%m-%d")}"
          )
end

Given('I visit the view post page for {string}') do |title|
  p = Post.find_by!(title: title)
  visit post_path(p)
end

Then('I should see images attached to {string} post') do |title|
  p = Post.find_by!(title: title)
  p.media_files.where(file_type: MediaFile::Type::IMAGE).each do |mf|
    # *= means "contains"
    expect(page).to have_css("img" +
                             "[src*='#{mf.file.filename}']" +
                             "[alt='#{mf.file.filename}']")
  end
end
