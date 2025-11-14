require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard" do
    it "redirects to login when not authenticated" do
      get dashboard_path
      expect(response).to redirect_to(login_path)
    end
  end
end
