# spec/requests/account_management_spec.rb
require "rails_helper"

RSpec.describe "Account management", type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  let(:user) { User.create!(email: "test@example.com", first_name: "Old", last_name: "Name") }

  before do
    # Stub current_user so we do not depend on session helpers here
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end

  describe "PATCH /account" do
    it "updates the user details" do
      patch account_path, params: {
        user: {
          first_name: "NewFirst",
          last_name: "NewLast"
        }
      }

      expect(response).to redirect_to(dashboard_path)
      follow_redirect!

      expect(user.reload.first_name).to eq("NewFirst")
      expect(user.last_name).to eq("NewLast")
    end

    it "adds or replaces the profile picture" do
      file = fixture_file_upload("test_jpg_image.jpg", "image/jpeg")

      patch account_path, params: {
        user: {
          first_name: user.first_name,
          last_name: user.last_name
        },
        profile_picture_file: file
      }

      expect(response).to redirect_to(dashboard_path)
      expect(user.reload.profile_picture).to be_present
      expect(user.profile_picture.file).to be_attached
    end

    it "removes the profile picture when requested" do
      # Seed an existing profile picture first
      file = fixture_file_upload("test_jpg_image.jpg", "image/jpeg")

      patch account_path, params: {
        user: {
          first_name: user.first_name,
          last_name: user.last_name
        },
        profile_picture_file: file
      }
      user.reload
      expect(user.profile_picture).to be_present

      patch account_path, params: {
        user: {
          first_name: user.first_name,
          last_name: user.last_name
        },
        remove_profile_picture: "1"
      }

      expect(response).to redirect_to(dashboard_path)
      expect(user.reload.profile_picture).to be_nil
    end
  end

  describe "DELETE /account" do
    it "deletes the user and redirects to login" do
      delete account_path

      expect(response).to redirect_to(login_path)
      expect(User.exists?(user.id)).to be false
    end
  end
end
