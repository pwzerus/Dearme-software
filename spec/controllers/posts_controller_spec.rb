require "rails_helper"

RSpec.describe PostsController, type: :controller do
  let(:user) { User.create!(email: "viewer@example.com", first_name: "View", last_name: "Er") }

  before do
    session[:user_id] = user.id
  end

  describe "GET #index" do
    it "sets show_status_filter and uses filtered posts" do
      allow(controller).to receive(:filter_posts_of).with(user).and_return([])

      get :index

      expect(controller.instance_variable_get(:@show_status_filter)).to be true
      expect(controller.instance_variable_get(:@posts)).to eq([])
      expect(controller.instance_variable_get(:@filter_url)).to eq(posts_path)
      expect(response).to have_http_status(:ok)
    end
  end
end
