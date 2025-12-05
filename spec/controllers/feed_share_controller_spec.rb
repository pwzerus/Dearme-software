require "rails_helper"

RSpec.describe FeedShareController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  let(:viewer) { User.create!(email: "viewer@example.com", first_name: "View", last_name: "Er") }
  let(:other_user) { User.create!(email: "owner@example.com", first_name: "Own", last_name: "Er") }
  let(:token_double) { instance_double(FeedShareToken, token: "abc123") }

  before do
    session[:user_id] = viewer.id
  end

  describe "GET #index" do
    it "assigns the share feed URL when the token is available" do
      allow(controller).to receive(:current_user).and_return(viewer)
      allow(viewer).to receive(:feed_share_token).and_return(token_double)

      get :index

      expect(controller.instance_variable_get(:@share_user_feed_url))
        .to eq(share_user_feed_url(token: "abc123"))
      expect(response).to have_http_status(:ok)
    end

    it "rescues errors and redirects with a flash when token fetch fails" do
      allow(controller).to receive(:current_user).and_return(viewer)
      allow(viewer).to receive(:feed_share_token).and_raise("boom")

      get :index

      expect(flash[:error]).to include("boom")
      expect(response).to redirect_to(dashboard_path)
    end
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

    it "redirects with notice when attempting to share feed with self" do
      allow(TokenHandlerService).to receive(:retrieve_hash_from_token)
        .and_return({
          user_id: viewer.id,
          expires_at: 1.hour.from_now.iso8601
        })

      get :share_user_feed, params: { token: "selftoken" }

      expect(flash[:notice]).to eq("Cannot share feed with self!")
      expect(response).to redirect_to(dashboard_path)
    end

    it "creates/updates share access and redirects to shared feeds on success" do
      travel_to Time.zone.parse("2024-06-01 10:00:00") do
      allow(TokenHandlerService).to receive(:retrieve_hash_from_token)
        .and_return({
          user_id: other_user.id,
          expires_at: 1.hour.from_now.iso8601
        })

        get :share_user_feed, params: { token: "goodtoken" }

        uvu = UserViewUser.find_by(viewer: viewer, viewee: other_user)
        expect(uvu).not_to be_nil
        expect(uvu.expires_at).to be_within(1.second).of(1.hour.from_now)
        expect(flash[:notice]).to eq("Shared feed access successful")
        expect(response).to redirect_to(shared_user_feeds_path)
      end
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

    it "renders posts index for a valid shared feed" do
      UserViewUser.create!(
        viewer: viewer,
        viewee: other_user,
        expires_at: 1.day.from_now
      )
      allow(controller).to receive(:filter_posts_of).with(other_user).and_return(Post.none)

      get :shared_user_feed, params: { user_id: other_user.id }

      expect(controller.instance_variable_get(:@user)).to eq(other_user)
      expect(controller.instance_variable_get(:@filter_url)).to eq(shared_user_feed_path(other_user))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #shared_user_feeds" do
    it "assigns only active shared feeds ordered by most recent" do
      active = UserViewUser.create!(
        viewer: viewer,
        viewee: other_user,
        expires_at: 2.hours.from_now,
        updated_at: 2.minutes.ago
      )
      UserViewUser.create!(
        viewer: viewer,
        viewee: User.create!(email: "expired@example.com", first_name: "Ex", last_name: "Pired"),
        expires_at: 1.hour.ago,
        updated_at: 1.minute.ago
      )

      get :shared_user_feeds

      expect(controller.instance_variable_get(:@current_user_view_users)).to eq([ active ])
    end
  end
end
