Given('the post {string} is tagged with {string}') do |post_title, tag_title|
  post = Post.find_by!(title: post_title)
  tag  = Tag.find_by!(title: tag_title)

  PostTag.find_or_create_by!(post: post, tag: tag)
end

Given('the post {string} is not tagged with {string}') do |post_title, tag_title|
  post = Post.find_by!(title: post_title)
  tag  = Tag.find_by!(title: tag_title)

  PostTag.where(post: post, tag: tag).delete_all
end

When('I check the tag {string} for this post') do |tag_title|
  # Assumes the post edit form has a checkbox labeled with the tag title,
  # e.g. <label>Important</label> with an associated checkbox.
  check tag_title
end

When('I uncheck the tag {string} for this post') do |tag_title|
  uncheck tag_title
end

Then('the post {string} should be tagged with {string}') do |post_title, tag_title|
  post = Post.find_by!(title: post_title)
  tag  = Tag.find_by!(title: tag_title)

  expect(PostTag.exists?(post: post, tag: tag)).to be true
end

Then('the post {string} should not be tagged with {string}') do |post_title, tag_title|
  post = Post.find_by!(title: post_title)
  tag  = Tag.find_by!(title: tag_title)

  expect(PostTag.exists?(post: post, tag: tag)).to be false
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
