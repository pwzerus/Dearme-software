require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:test_user) {
      User.create!(
              email: "solidsnake@liquid.com",
              first_name: "Solid",
              last_name: "Snake"
              )
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

  it "could have multiple associated posts" do
    p1 = Post.create!(creator: test_user, location: test_location)
    p2 = Post.create!(creator: test_user, location: test_location)

    expect(test_location.posts).to match_array([p1, p2])
    expect(p1.location).to eq(test_location)
    expect(p2.location).to eq(test_location)
  end
end
