require 'rails_helper'

RSpec.describe PostTag, type: :model do
  let(:test_user) {
      User.create!(email: "solidsnake@liquid.com",
                   first_name: "Solid",
                   last_name: "Liquid")
  }

  it "should be able to associate a post with multiple tags" do
    t1 = Tag.create!(creator: test_user, title: "title 1")
    t2 = Tag.create!(creator: test_user, title: "title 2")

    p = Post.create!(creator: test_user, title: "Some post")
    p.tags << t1
    p.tags << t2

    expect(p.tags).to match_array([t1, t2])
  end

   it "should be able to associate a tag with multiple posts" do
    p1 = Post.create!(creator: test_user, title: "title 1")
    p2 = Post.create!(creator: test_user, title: "title 2")

    t = Tag.create!(creator: test_user, title: "Some post")
    t.posts << p1
    t.posts << p2

    expect(t.posts).to match_array([p1, p2])
  end

  it "shouldn't associate tag created by one with post created by another" do
    another_user = User.create!(email: "ocelot@bigboss.com",
                                first_name: "Revolver",
                                last_name: "Ocelot")

    test_user_tag = Tag.create!(creator: test_user, title: "Some tag")
    another_user_post = Post.create!(creator: another_user, title: "Some post")

    pt = PostTag.new(tag: test_user_tag, post: another_user_post)
    expect(pt).to be_invalid
  end
end
