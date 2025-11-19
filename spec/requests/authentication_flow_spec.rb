# spec/requests/authentication_flow_spec.rb
require "rails_helper"

RSpec.describe "Authentication flow", type: :request do
  let(:user) do
    User.create!(
      email:      "test-user@example.com",
      first_name: "Test",
      last_name:  "User"
    )
  end

  describe "accessing the dashboard" do
    context "when not signed in" do
      it "redirects to the login page with a flash message" do
        get dashboard_path

        expect(response).to redirect_to(login_path)
        follow_redirect!

        expect(response.body).to include("Login required!")
      end
    end

    context "when signed in" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user).and_return(user)
      end

      it "shows the dashboard" do
        get dashboard_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Dashboard")
        expect(response.body).to include("Welcome")
      end
    end
  end

  describe "logging out" do
    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user).and_return(user)
    end

    it "clears the session and shows the logout message on login page" do
      delete logout_path

      expect(response).to redirect_to(login_path)

      follow_redirect!

      expect(response.body).to include("Logged out successfully!")
      expect(response.body).to include("Continue with Google")
    end
  end
end
