require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:test_user) {
      User.create!(email: "solidsnake@liquid.com",
                   first_name: "Solid",
                   last_name: "Snake")
  }

  let(:test_location) {
      Location.create!(
              address_line_1: "Mata Mandir",
              city: "Bhopal",
              state: "Madhya Pradesh",
              zip_code: "462003",
              country: "IN"
              )
  }

  describe "validations" do
    let(:valid_post_attributes) {
      {
        creator: test_user,
        location: test_location
      }
    }

    it "should not be able to exist without a creator user" do
      p = Post.new(valid_post_attributes.except(:creator))
      expect(p).to be_invalid
    end

    it "should be able to exist without a location" do
      p = Post.new(valid_post_attributes.except(:location))
      expect(p).to be_valid
    end
  end

  it "should belong to the creator user" do
    p = Post.create!(creator: test_user)
    expect(p.creator).to be(test_user)
  end

  it "should allow creator to have multiple posts" do
    p1 = Post.create!(creator: test_user, title: "Post 1")
    p2 = Post.create!(creator: test_user, title: "Post 2")
    expect(test_user.posts).to match_array([ p1, p2 ])
  end

  it "should get destroyed on destruction of creator user" do
    test_post_title = "Post 1"

    t = Post.create!(creator: test_user, title: test_post_title)

    expect { test_user.destroy! }.to change { Post.count }.by(-1)
    expect(Post.find_by(title: test_post_title)).to be_nil
  end
end
