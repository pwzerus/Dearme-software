RSpec.shared_examples "validate against post handling by non creator" do |http_method, action|
  context "when non creator tries to handle a post" do
    # Using FILE so that there's very very less chance of emails of
    # users created in this file clashing with existing emails of users
    # created by the test that includes this shared example.
    #
    # In the rare chance that they do clash, the writer of the test should
    # reconsider their naming choices of why their user has such a weird
    # name as the following (and ideally we wouldn't need to change the
    # names of users of this test)
    #
    # (Emails can't clash as emails of app users must be unique)
    let(:name_typical_to_this_test) {
      File.basename(__FILE__, ".rb") + "name_is_bond_james_bond"
    }

    let(:creator_user) do
      User.create!(
              email: "#{name_typical_to_this_test}_creator@user.com",
              first_name: "Creator",
              last_name: "Of the world"
              )
    end

    let(:non_creator_user) do
      User.create!(
              email: "#{name_typical_to_this_test}_non_creator@user.com",
              first_name: "Touch",
              last_name: "OtherPeoplePosts"
              )
    end

    let(:test_post) do
      Post.create!(creator: creator_user, title: "DVNO")
    end

    before do
      # Let non creator user be the logged in user
      allow_any_instance_of(ApplicationController)
       .to receive(:current_user).and_return(non_creator_user)
    end

    it "should set flash alert" do
      send(http_method, action, params: { id: test_post })
      expect(flash[:alert]).not_to be_nil
    end

    it "should redirect back to dashboard" do
      send(http_method, action, params: { id: test_post })
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
