require 'rails_helper'

RSpec.describe User, type: :model do
  let(:test_user) {
      User.create!(email: "solidsnake@liquid.com",
                   first_name: "Solid",
                   last_name: "Snake")
  }

  describe "#feed_share_token" do
    def validate_active_token(tok, expected_owner)
      expect(tok).to eq(expected_owner.internal_feed_share_token)

      expect(tok.token).not_to be_nil
      expect(tok.user).to eq(expected_owner)
      expect(tok.expires_at).to be > Time.current
    end

    it "should associate a feed share token with the user if none's present" do
      expect(test_user.internal_feed_share_token).to be_nil
      tok = test_user.feed_share_token
      validate_active_token(tok, test_user)
    end

    context "user's existing token has expired" do
      let(:test_token) { test_user.feed_share_token }

      before do
        # Turn the token associated with the user into an expired one
        test_token.update!(expires_at: Time.current - 1.day)
      end

      it "should regenerate a fresh token and associate that with the user" do
        # internal feed share token should be expired at this point,
        # so #feed_share_token should generate a new one.
        expect(test_user.internal_feed_share_token.expired?).to be true

        tok = test_user.feed_share_token
        validate_active_token(tok, test_user)
      end
    end
  end
end
