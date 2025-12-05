# spec/controllers/login_controller_spec.rb
require "rails_helper"

RSpec.describe LoginController, type: :controller do
  let(:user_email)  { "test-user@example.com" }
  let(:first_name)  { "Test" }
  let(:last_name)   { "User" }

  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "1234567890",
      info: {
        email:      user_email,
        first_name: first_name,
        last_name:  last_name
      }
    )
  end

  before do
    OmniAuth.config.test_mode = true
  end

  describe "GET #new" do
    it "renders the login page successfully" do
      get :new

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #omniauth_callback" do
    before do
      request.env["omniauth.auth"] = omniauth_hash
    end

    context "when the user does not exist yet" do
      it "creates a new user, stores the user id in session, and redirects to dashboard" do
        expect {
          get :omniauth_callback, params: { provider: "google_oauth2" }
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to      eq(user_email)
        expect(user.first_name).to eq(first_name)
        expect(user.last_name).to  eq(last_name)

        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when the user already exists" do
      let!(:existing_user) do
        User.create!(
          email:      user_email,
          first_name: "Old",
          last_name:  "Name"
        )
      end

      it "reuses the existing user and does not create a duplicate" do
        expect {
          get :omniauth_callback, params: { provider: "google_oauth2" }
        }.not_to change(User, :count)

        expect(session[:user_id]).to eq(existing_user.id)
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when user was trying to visit another url without loggin in" do
      # No specific reason for choosing this url, could use any route url
      # for the sake of this test and it should pass
      let(:test_url) { posts_path }

      before do
       session[:original_url_to_visit] = test_url
      end

      it "should redirect to that url after successful login" do
        get :omniauth_callback, params: { provider: "google_oauth2" }

        # should clear it before redirecting
        expect(session[:original_url_to_visit]).to be_nil

        expect(response).to redirect_to(test_url)
      end
    end

    context "when saving the user raises an error" do
      before do
        allow(User).to receive(:find_or_initialize_by)
          .and_return(User.new)
        allow_any_instance_of(User).to receive(:save!)
          .and_raise(StandardError.new("boom"))
      end

      it "logs an error, sets a flash alert, and redirects to login" do
        expect(Rails.logger).to receive(:error).with(/Authentication failed: boom/)

        get :omniauth_callback, params: { provider: "google_oauth2" }

        expect(flash[:alert]).to match(/Authentication failed! boom/)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET #failure" do
    it "sets a flash alert and redirects to login" do
      get :failure, params: { message: "access_denied" }

      expect(flash[:alert]).to eq("Authentication failed: access_denied")
      expect(response).to redirect_to(login_path)
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { User.create!(email: user_email, first_name: first_name, last_name: last_name) }

    before do
      session[:user_id] = user.id
    end

    it "clears the session, sets a flash notice, and redirects to login" do
      delete :destroy

      expect(session[:user_id]).to be_nil
      expect(flash[:notice]).to eq("Logged out successfully!")
      expect(response).to redirect_to(login_path)
    end
  end
end
