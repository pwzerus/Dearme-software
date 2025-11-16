require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:test_user) {
      User.create!(email: "solidsnake@liquid.com",
                   first_name: "Solid",
                   last_name: "Snake")
  }

  describe "attribute validations" do
    let(:valid_tag_attributes) {
      {
        creator: test_user,
        title: "Valid tag title"
      }
    }

    it "should get created with valid attributes" do
      t = Tag.new(valid_tag_attributes)
      expect(t).to be_valid
    end

    it "should not be able to exist without a creator user" do
      t = Tag.new(valid_tag_attributes.except(:creator))
      expect(t).not_to be_valid
    end

    it "should not be able to exist without a title" do
      t = Tag.new(valid_tag_attributes.except(:title))
      expect(t).not_to be_valid
    end
  end

  it "should have unique title per user" do
    repeated_title = "Booyah"

    Tag.create!(creator: test_user, title: repeated_title)

    t2 = Tag.new(creator: test_user, title: repeated_title)
    expect(t2).to be_invalid
  end

  it "should allow associating multiple tags with a user" do
    t1 = Tag.create!(creator: test_user, title: "title 1")
    t2 = Tag.create!(creator: test_user, title: "title 2")

    expect(test_user.tags).to match_array([t1, t2])
  end

  it "should belong to the creator user" do
    t = Tag.create!(creator: test_user, title: "title 1")
    expect(t.creator).to eq(test_user)
  end

  it "should get destroyed when creator is destroyed" do
    test_tag_title = "title 1"

    t = Tag.create!(creator: test_user, title: test_tag_title)

    expect{ test_user.destroy! }.to change { Tag.count }.by(-1)
    expect(Tag.find_by(title: test_tag_title)).to be_nil
  end
end
