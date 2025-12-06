RSpec.shared_examples "handling of non existent post id" do |http_method, action|
  context "when post with an id does not exist" do
    let(:non_existent_id) { -1 }
    it "should set flash alert" do
      send(http_method, action, params: { id: non_existent_id })
      expect(flash[:alert]).not_to be_nil
    end

    it "should redirect back to dashboard" do
      send(http_method, action, params: { id: non_existent_id })
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
