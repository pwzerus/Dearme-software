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

  it "should use be an archived post by default" do
    t = Post.create!(creator: test_user)
    expect(t.archived).to be true
  end

  describe "#duplicate_for" do
    let(:creator) {
      User.create!(
        email: "creator@example.com",
        first_name: "Creator",
        last_name: "User"
      )
    }

    let(:other_user) {
      User.create!(
        email: "other@example.com",
        first_name: "Other",
        last_name: "User"
      )
    }

    let(:original_post) {
      Post.create!(
        creator: creator,
        title: "Original Title",
        description: "Original description",
        archived: true
      )
    }

    let(:image_path) {
      Rails.root.join("spec", "fixtures", "files", "test_png_image.png")
    }

    before do
      # add a tag
      tag = Tag.create!(title: "Travel", creator: creator)
      original_post.tags << tag

      # add a media file
      mf = original_post.media_files.new(file_type: MediaFile::Type::IMAGE)
      mf.file.attach(
        io: File.open(image_path),
        filename: "test_png_image.png",
        content_type: "image/png"
      )
      mf.save!
    end

    it "creates a new post for the given user with copied attributes" do
      copy = original_post.duplicate_for(other_user)

      expect(copy.id).not_to eq(original_post.id)
      expect(copy.creator).to eq(other_user)
      expect(copy.title).to eq("Copy of Original Title")
      expect(copy.description).to eq(original_post.description)
      expect(copy.archived).to eq(original_post.archived)
    end

    context "when duplicating for the same creator" do
      it "reuses existing tags and does not create new tag records" do
        expect {
          original_post.duplicate_for(creator)
        }.not_to change { Tag.count }

        copy = Post.order(:created_at).last

        expect(copy.tags.map(&:title)).to match_array(original_post.tags.map(&:title))
        expect(copy.tags.map(&:creator_id).uniq).to eq([ creator.id ])
      end
    end

    context "when duplicating for a different user" do
      it "creates new tags for the new creator with the same titles" do
        expect {
          original_post.duplicate_for(other_user)
        }.to change { Tag.count }.by(original_post.tags.count)

        copy = Post.order(:created_at).last

        expect(copy.creator).to eq(other_user)
        expect(copy.tags.map(&:title)).to match_array(original_post.tags.map(&:title))
        expect(copy.tags.map(&:creator_id).uniq).to eq([ other_user.id ])
      end
    end

    it "copies media files and creates independent blobs" do
      copy = original_post.duplicate_for(other_user)

      expect(copy.media_files.count).to eq(original_post.media_files.count)

      original_blob = original_post.media_files.first.file.blob
      copied_blob   = copy.media_files.first.file.blob

      # should create a new blob, but with the same file content
      expect(copied_blob.id).not_to eq(original_blob.id)
      expect(copied_blob.filename).to eq(original_blob.filename)
      expect(copied_blob.byte_size).to eq(original_blob.byte_size)
    end
  end
end
