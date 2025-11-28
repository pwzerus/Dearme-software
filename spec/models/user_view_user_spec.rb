require 'rails_helper'

RSpec.describe UserViewUser, type: :model do
  let(:test_user_1) {
      User.create!(email: "solidsnake@liquid.com",
                   first_name: "Solid",
                   last_name: "Liquid")
  }

  let(:test_user_2) {
    User.create!(email: "liquidsnake@bigboss.com",
                 first_name: "Liquid",
                 last_name: "Snake")
  }

  let(:test_user_3) {
    User.create!(email: "nakedsnake@boss.com",
                 first_name: "Naked",
                 last_name: "Snake")
  }

  it "should allow a user to be viewed by multiple users" do
    # The syntax test_user_1.viewers << test_user_2 does not work
    # since the assocation is not via :user symbol but via :viewee
    # symbol, so its not viewer "views" user but rather viewer "views" viewee
    #
    # so that syntax is able to identify that test_user_2 is the viewer
    # but not able to pinpoint that test_user_1 is supposed to be the
    # viewee, hence needing the following explicit creation syntax
    UserViewUser.create!(
            viewee: test_user_1,
            viewer: test_user_2
            )

     UserViewUser.create!(
            viewee: test_user_1,
            viewer: test_user_3
            )

    # Test user 1 is viewed by user 2 and 3
    expect(test_user_1.viewers).to match_array([ test_user_2, test_user_3 ])

    # Test user 2 is viewing test user 1
    expect(test_user_2.viewees).to match_array([ test_user_1 ])
    # Test user 3 is viewing test user 1
    expect(test_user_3.viewees).to match_array([ test_user_1 ])
  end

  it "should allow a user to view multiple users" do
    # The syntax test_user_1.viewees << test_user_2 does not work
    # since the assocation is not via :user symbol but via :viewer
    # symbol, so its not user "views" viewee but rather viewer "views" viewee
    #
    # so that syntax is able to identify that test_user_2 is the viewee
    # but not able to pinpoint that test_user_1 is supposed to be the
    # viewer, hence needing the following explicit creation syntax
    UserViewUser.create!(
            viewer: test_user_1,
            viewee: test_user_2
            )

     UserViewUser.create!(
            viewer: test_user_1,
            viewee: test_user_3
            )

    expect(test_user_1.viewees).to match_array([ test_user_2, test_user_3 ])
    expect(test_user_2.viewers).to match_array([ test_user_1 ])
    expect(test_user_3.viewers).to match_array([ test_user_1 ])
  end

  context "expiry related tests" do
    let(:params_without_expiry_datetime) {
      {
        viewer: test_user_1,
        viewee: test_user_2
      }
    }

    def validate_active(user_view_user)
      expect(user_view_user.active?).to be true
      expect(user_view_user.expired?).to be false
      expect(UserViewUser.active).to include(user_view_user)
    end

    def validate_expired(user_view_user)
      expect(user_view_user.active?).to be false
      expect(user_view_user.expired?).to be true
      expect(UserViewUser.active).not_to include(user_view_user)
    end

    it "should flag viewers with no expiry date-time as active" do
      uvu = UserViewUser.create!(params_without_expiry_datetime)
      validate_active(uvu)
    end

    it "should flag viewers with non-expired date-time as active" do
      uvu = UserViewUser.create!(
              params_without_expiry_datetime.merge!(
                  expires_at: Time.current + 1.minute
                  )
              )
      validate_active(uvu)
    end

     it "should flag viewers with expired date-time as expired" do
      uvu = UserViewUser.create!(
              params_without_expiry_datetime.merge!(
                  expires_at: Time.current - 1.minute
                  )
              )
      validate_expired(uvu)
    end
  end

  # This feature of viewing is not a mapping to view access, but
  # rather meant for sharing (with view access), so self loop sharing
  # feed with oneself doesn't make sense here.
  it "shouldn't allow user to themselves" do
    expect {
      UserViewUser.create!(
              viewer: test_user_1,
              viewee: test_user_1
              )
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
