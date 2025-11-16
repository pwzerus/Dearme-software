require 'rails_helper'

RSpec.describe MediaFile, type: :model do
  let(:test_user) {
    User.create!(email: "solidsnake@liquid.com",
                 first_name: "Solid",
                 last_name: "Snake")
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
      p = Post.create!(creator: test_user)

      MediaFile.create!(
              parent: p,
              file: test_image_file,
              file_type: MediaFile::Type::IMAGE)

      MediaFile.create!(
              parent: p,
              file: test_video_file,
              file_type: MediaFile::Type::VIDEO)

      MediaFile.create!(
              parent: p,
              file: test_audio_file,
              file_type: MediaFile::Type::AUDIO)

      # Load the associations (the new media files associated
      # with the post
      p.reload

      expect(p.media_files.length).to eq(3)

      post_media_file_names = p.media_files.map do |mf|
        mf.file.filename.to_s
      end

      expect(post_media_file_names).to match_array([
          test_image_file.original_filename,
          test_audio_file.original_filename,
          test_video_file.original_filename
      ])
    end
  end
end
