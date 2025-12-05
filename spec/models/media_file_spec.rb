require 'rails_helper'

RSpec.describe MediaFile, type: :model do
  let(:test_user) {
    User.create!(email: "solidsnake@liquid.com",
                 first_name: "Solid",
                 last_name: "Snake")
  }

  let(:test_post) {
    Post.create!(creator: test_user)
  }

  let(:test_image_file) {
    fixture_file_upload("test_jpg_image.jpg",
                        'image/jpeg')
  }

  let(:test_video_file) {
    fixture_file_upload("test_mp4_video.mp4",
                        'video/mp4')
  }

  let(:test_audio_file) {
    fixture_file_upload("test_mp3_audio.mp3",
                        'audio/mp3')
  }

  describe "#belongs_to_user?" do
    let(:mf_attrs_except_parent) {
      {
        file: test_image_file,
        file_type: MediaFile::Type::IMAGE
      }
    }

    it "should return true when belongs to user" do
      mf = MediaFile.create!(mf_attrs_except_parent.merge(parent: test_user))
      expect(mf.belongs_to_user?).to be true
    end

    it "should return false when doesn't belong to a user" do
      mf = MediaFile.create!(mf_attrs_except_parent.merge(parent: test_post))
      expect(mf.belongs_to_user?).to be false
    end
  end

  describe "#belongs_to_post?" do
    let(:mf_attrs_except_parent) {
      {
        file: test_image_file,
        file_type: MediaFile::Type::IMAGE
      }
    }

    it "should return true when belongs to post" do
      mf = MediaFile.create!(mf_attrs_except_parent.merge(parent: test_post))
      expect(mf.belongs_to_post?).to be true
    end

    it "should return false when doesn't belong to a post" do
      mf = MediaFile.create!(mf_attrs_except_parent.merge(parent: test_user))
      expect(mf.belongs_to_post?).to be false
    end
  end

  describe "profile picture" do
    it "should allow user to have a profile picture" do
      expect(test_user.profile_picture).to be_nil

      profile_picture = MediaFile.create!(
              file: test_image_file,
              file_type: MediaFile::Type::IMAGE,
              parent: test_user
              )

      # So that the association gets set up User <- MediaFile
      # via the profile picture.
      test_user.reload

      expect(test_user.profile_picture.file).to be_attached
      expect(test_user.profile_picture.file.filename.to_s).to eq(test_image_file.original_filename)
    end
  end

  describe "media files associated with a post" do
    it "should allow associating multiple files with a post" do
      MediaFile.create!(
              parent: test_post,
              file: test_image_file,
              file_type: MediaFile::Type::IMAGE)

      MediaFile.create!(
              parent: test_post,
              file: test_video_file,
              file_type: MediaFile::Type::VIDEO)

      MediaFile.create!(
              parent: test_post,
              file: test_audio_file,
              file_type: MediaFile::Type::AUDIO)

      # Load the associations (the new media files associated
      # with the post
      test_post.reload

      expect(test_post.media_files.length).to eq(3)

      post_media_file_names = test_post.media_files.map do |mf|
        mf.file.filename.to_s
      end

      expect(post_media_file_names).to match_array([
          test_image_file.original_filename,
          test_audio_file.original_filename,
          test_video_file.original_filename
      ])
    end
  end

  describe ".type_from_content_type" do
    def type_checking_helper(content_types, expected_media_type)
      content_types.each do |ct|
        expect(MediaFile.type_from_content_type(ct)).to eq(expected_media_type)
      end
    end

    context "image content type" do
     let(:content_types) {
          [ "image/jpeg", "image/png" ]
      }

      it "should return media file image type" do
        type_checking_helper(content_types, MediaFile::Type::IMAGE)
      end
    end

    context "video content type" do
      let(:content_types) {
          [ "video/mp4", "video/ogg" ]
      }

      it "should return media file video type" do
        type_checking_helper(content_types, MediaFile::Type::VIDEO)
      end
    end

    context "audio content type" do
      let(:content_types) {
          [ "audio/mpeg", "audio/mp3", "audio/wav" ]
      }

      it "should return media file audio type" do
        type_checking_helper(content_types, MediaFile::Type::AUDIO)
      end
    end

    context "unknown content type" do
      let(:bad_content_type) { "are you kidding ?" }
      it "should raise argument error" do
        expect {
            MediaFile.type_from_content_type(bad_content_type)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
