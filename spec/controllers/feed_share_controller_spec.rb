require "rails_helper"

RSpec.describe FeedShareController, type: :controller do
  let(:viewer) { User.create!(email: "viewer@example.com", first_name: "View", last_name: "Er") }
  let(:other_user) { User.create!(email: "owner@example.com", first_name: "Own", last_name: "Er") }

  before do
    session[:user_id] = viewer.id
  end

  describe "GET #share_user_feed" do
    it "rescues and redirects when token details are invalid" do
      allow(TokenHandlerService).to receive(:retrieve_hash_from_token)
        .with("badtoken")
        .and_return({ user_id: nil, expires_at: nil })

      get :share_user_feed, params: { token: "badtoken" }

      expect(flash[:error]).to include("Invalid feed share information")
      expect(response).to redirect_to(dashboard_path)
    end

    it "rescues and redirects when the token is expired" do
      allow(TokenHandlerService).to receive(:retrieve_hash_from_token)
        .with("expiredtoken")
        .and_return({
          user_id: other_user.id,
          expires_at: 1.day.ago.iso8601
        })

      get :share_user_feed, params: { token: "expiredtoken" }

      expect(flash[:error]).to include("Received expired shared feed token")
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "GET #shared_user_feed" do
    it "rescues and redirects when the feed has not been shared with the viewer" do
      get :shared_user_feed, params: { user_id: other_user.id }

      expect(flash[:error]).to include("User's feed hasn't been shared with you")
      expect(response).to redirect_to(dashboard_path)
    end

    it "rescues and redirects when the feed share has expired" do
      UserViewUser.create!(
        viewer: viewer,
        viewee: other_user,
        expires_at: 1.day.ago
      )

      get :shared_user_feed, params: { user_id: other_user.id }

      expect(flash[:error]).to include("User feed shared with you has expired")
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
