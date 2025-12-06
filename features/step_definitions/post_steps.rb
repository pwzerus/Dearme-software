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

def create_post_helper(attrs)
  creator_email = attrs["creator_email"] ? attrs["creator_email"] :
                                           TEST_USER_EMAIL
  creator = User.find_by!(email: creator_email)

  p = Post.create!(
          title: attrs["title"] ? attrs["title"] : "Some default title",
          creator: creator,
          archived: attrs.key?("archived") ?
                      ActiveModel::Type::Boolean.new.cast(attrs["archived"]) :
                      Post.new.archived
          )

  if attrs["created_at"].present?
    p.update_column(:created_at, Time.zone.parse(attrs["created_at"]))
  end

  # A string consisting of comma separated file names
  images_str = attrs["images"]
  if images_str.present?
    # arr.map(&:strip) is equivalent to
    # arr.map { |elem| elem.strip }
    images_str.split(",").map(&:strip).each do |filename|
      mf = p.media_files.new(file_type: MediaFile::Type::IMAGE)

      filepath = get_test_file_path_from_name(filename)
      mf.file.attach(
              io: File.open(filepath),
              filename: filename,
              content_type: Marcel::MimeType.for(filepath)
              )
      mf.save!
    end
  end

  # Associate tags if provided as comma-separated titles
  tags_str = attrs["tags"]
  if tags_str.present?
    tags_str.split(",").map(&:strip).reject(&:blank?).each do |title|
      tag = Tag.where(creator: creator, title: title).first_or_create!
      p.tags << tag unless p.tags.include?(tag)
    end
  end
end

Given('a post exists with:') do |table|
  # Converts the table into a hash with first column as keys
  # and second column elements as corresponding values
  attrs = table.rows_hash
  create_post_helper(attrs)
end

Given('posts exist with following duplicated details for multiple users:') do |table|
  attrs = table.rows_hash

  # arr.map(&:strip) is equivalent to
  # arr.map { |elem| elem.strip }
  creator_emails = attrs["creator_emails"]

  # Create the post with same details for each of the creators
  creator_emails.split(",").map(&:strip).each do |creator_email|
    post_attrs = attrs.dup
    post_attrs.delete("creator_emails")
    post_attrs["creator_email"] = creator_email
    create_post_helper(post_attrs)
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
  validate_page_shows_media_file(filename, MediaFile::Type::IMAGE)
end

Then('I should be on the edit post page for {string}') do |title|
  p = Post.find_by!(title: title)
  expect(page).to have_current_path(edit_post_path(p))
end

# Why this ugly regex ?
# Because that allows me to have an optional parameter creator_email
# in the gherkin style step which callers can use when they want to
# differentiate cases when posts have same title but different creators
# (If no optional creator email provided, post title is used to find the
# post)
#
# "([^"]+)" - the surrounding quotes match the literal quotes in feature step
# () parenthesis for grouping
# [^"] means a character class which is negation of " (double quote)
# [^"]+ means captures one or more of any character except " (double quote)
#
# The (?: for creator "([^"]+)")?$ i.e (?: ...)?
# is for the optional parameter creator emaid, the ? at the end makes
# it optional and (?: ) is for non capturing grouping
# (See:
# https://stackoverflow.com/questions/18346348/optional-parameter-in-cucumber
# )
#
# The $ at the end to ensure that nothing extra after creator email id
Then(
  /I should be on the view post page for "([^"]+)"(?: for creator "([^"]+)")?$/
  ) do |title, creator_email|
  if creator_email.nil?
    p = Post.find_by!(title: title)
  else
    creator = User.find_by!(email: creator_email)
    p = Post.find_by!(title: title, creator: creator)
  end
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

Then('a post should exist with:') do |table|
  attrs = table.rows_hash

  title         = attrs["title"]
  creator_email = attrs["creator_email"]

  post = Post.find_by(title: title)
  expect(post).not_to be_nil

  if creator_email.present?
    expect(post.creator.email).to eq(creator_email)
  end
end

Given('I can view posts created by {string}') do |creator_email|
  viewer = User.find_by!(email: TEST_USER_EMAIL)
  creator = User.find_by!(email: creator_email)

  UserViewUser.create!(
    viewer: viewer,
    viewee: creator,
    expires_at: Time.current + 5.minutes
  )
end

When('I attempt to copy a post that does not exist') do
  # Use an obviously invalid id that set_post! will not find
  page.driver.submit :post, duplicate_post_path(-1), {}
end
