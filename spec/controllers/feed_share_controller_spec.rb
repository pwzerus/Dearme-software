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

      expect(flash[:error]).not_to be_nil
      expect(response).to redirect_to(dashboard_path)
    end

    it "rescues and redirects when the feed share has expired" do
      UserViewUser.create!(
        viewer: viewer,
        viewee: other_user,
        expires_at: 1.day.ago
      )

      get :shared_user_feed, params: { user_id: other_user.id }

      expect(flash[:error]).not_to be_nil
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

  # current user tries to revoke feed access of another user
  # (so that the other user can no longer access current user's
  # feed)
  describe "#DELETE stop_feed_share" do
    let(:test_end_point) { :stop_feed_share }
    let(:test_user_1) { viewer }
    let(:test_user_2) { other_user }
    let(:test_user_3) {
        User.create!(
                email: "third_user_stop_share_feed@test.com",
                first_name: "ThirdUser",
                last_name: "StopShareFeed"
                )
    }

    before do
      # All the further tests for this method should set current_user
      # and whatever they'll set it to would act as the logged in user.
      session[:user_id] = current_user
    end

    # Happy path 1: User ignores shared feed of another user
    context "current user can access viewee's feed" do
      let(:current_user) { test_user_1 }
      let(:viewer_user) { current_user }
      let(:viewee_user) { test_user_2 }

      before do
        UserViewUser.create!(
                viewer: viewer_user,
                viewee: viewee_user,
                expires_at: Time.current + 5.minutes
                )
      end

      it "should actually stop feed share" do
        expect {
            delete test_end_point, params: {
                             viewer_id: viewer_user.id,
                             viewee_id: viewee_user.id
                           }
        }.to change(UserViewUser, :count).by(-1)

         uvu = UserViewUser.find_by(viewer: viewer_user, viewee: viewee_user)
         expect(uvu).to be_nil
      end

      it "should set flash notice and redirect to shared feeds page" do
        delete test_end_point, params: {
                             viewer_id: viewer_user.id,
                             viewee_id: viewee_user.id
                           }
        expect(flash[:notice]).not_to be_nil
        expect(response).to redirect_to(shared_user_feeds_path)
      end
    end

    # Happy path 2: User revokes shared feed access of viewer
    context "current user's feed can be access by viewer" do
      let(:current_user) { test_user_1 }
      let(:viewer_user) { test_user_2 }
      let(:viewee_user) { current_user }

      before do
        UserViewUser.create!(
                viewer: viewer_user,
                viewee: viewee_user,
                expires_at: Time.current + 5.minutes
                )
      end

      it "should actually stop feed share" do
        expect {
            delete test_end_point, params: {
                             viewer_id: viewer_user.id,
                             viewee_id: viewee_user.id
                           }
        }.to change(UserViewUser, :count).by(-1)

         uvu = UserViewUser.find_by(viewer: viewer_user, viewee: viewee_user)
         expect(uvu).to be_nil
      end

      it "should set flash notice and redirect to feed manager page" do
        delete test_end_point, params: {
                             viewer_id: viewer_user.id,
                             viewee_id: viewee_user.id
                           }
        expect(flash[:notice]).not_to be_nil
        expect(response).to redirect_to(feed_share_manager_path)
      end
    end

    context "current user neither viewer nor viewee" do
      let(:viewer_user) { test_user_1 }
      let(:viewee_user) { test_user_2 }
      let(:current_user) { test_user_3 }

      before do
        # Have an active shared feed between viewer and viewee
        UserViewUser.create!(
                viewer: viewer_user,
                viewee: viewee_user,
                expires_at: Time.current + 5.minutes
                )
      end

      it "should set flash error and redirect to dashboard" do
        delete test_end_point, params: {
                             viewer_id: viewer_user.id,
                             viewee_id: viewee_user.id
                           }
        expect(flash[:error]).not_to be_nil
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "viewer and viewee have no shared feed between them" do
      let(:current_user) { test_user_1 }
      let(:viewer_user) { test_user_1 }
      let(:viewee_user) { test_user_2 }

      before do
        # There exists none at this point, still destroying
        # just for the sake of safe programming and explicitly
        # specifying what the precondition is.
        UserViewUser.where(
                viewer: viewer_user,
                viewee: viewee_user).destroy_all
      end

      it "should set flash error and redirect to dashboard" do
        delete test_end_point, params: {
                             viewer_id: viewer_user.id,
                             viewee_id: viewee_user.id
                           }
        expect(flash[:error]).not_to be_nil
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "viewer and viewee had shared feed but it has expired" do
      let(:current_user) { test_user_1 }
      let(:viewer_user) { test_user_1 }
      let(:viewee_user) { test_user_2 }

      before do
        UserViewUser.create!(
                viewer: viewer_user,
                viewee: viewee_user,
                expires_at: Time.current - 5.minutes
                )
      end

      it "should set flash error and redirect to dashboard" do
        delete test_end_point, params: {
                             viewer_id: viewer_user.id,
                             viewee_id: viewee_user.id
                           }
        expect(flash[:error]).not_to be_nil
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
