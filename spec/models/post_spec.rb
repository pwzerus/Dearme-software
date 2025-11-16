require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:test_user) {
      User.create!(email: "solidsnake@liquid.com",
                   first_name: "Solid",
                   last_name: "Snake")
  }

  describe "validations" do
    it "should not be able to exist without a creator user" do
      p = Post.new(creator: nil)
      expect(p).to be_invalid
    end
  end

  it "should belong to the creator user" do
    p = Post.create!(creator: test_user)
    expect(p.creator).to be(test_user)
  end

  it "should allow creator to have multiple posts" do
    p1 = Post.create!(creator: test_user, title: "Post 1")
    p2 = Post.create!(creator: test_user, title: "Post 2")
    expect(test_user.posts).to match_array([p1, p2])
  end

  it "should get destroyed on destruction of creator user" do
    test_post_title = "Post 1"

    t = Post.create!(creator: test_user, title: test_post_title)

    expect{ test_user.destroy! }.to change { Post.count }.by(-1)
    expect(Post.find_by(title: test_post_title)).to be_nil
  end
end
