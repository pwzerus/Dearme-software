require 'rails_helper'

RSpec.describe FeedShareToken, type: :model do
  let(:test_user) {
      User.create!(email: "solidsnake@liquid.com",
                   first_name: "Solid",
                   last_name: "Snake")
  }

  def validate_active_feed_share_token(tok, expected_user)
    expect(tok.user).to eq(expected_user)
    expect(tok.token).not_to be_nil
    expect(tok.expires_at).to be > Time.current

    h = TokenHandlerService.retrieve_hash_from_token(tok.token)
    expect(h[:user_id]).to eq(expected_user.id)

    # We only want time upto seconds to match (any more precision
    # beyond that isn't needed)
    expect(Time.parse(h[:expires_at]).change(usec: 0))
      .to eq(tok.expires_at.change(usec: 0))
  end

  describe ".generate!" do
    it "should generate a token and associate it with the passed user" do
      tok = FeedShareToken.generate!(test_user)
      validate_active_feed_share_token(tok, test_user)
    end

    it "should use token handler service for generation" do
      mock_token_str = "doggy"
      allow(TokenHandlerService)
        .to receive(:generate_token_from_hash)
        .and_return(mock_token_str)

      tok = FeedShareToken.generate!(test_user)
      expect(tok.token).to eq(mock_token_str)
    end
  end

  describe "#expired?" do
    let(:attrs_without_expiry_time) {
      {
        user: test_user,
        token: "bla"
      }
    }

    it "should return true for expired tokens" do
      fst = FeedShareToken.create!(
        attrs_without_expiry_time.merge!(expires_at: Time.current - 1.hour)
        )
      expect(fst.expired?).to be true
    end

    it "should return true for expired tokens" do
      fst = FeedShareToken.create!(
        attrs_without_expiry_time.merge!(expires_at: Time.current + 1.hour)
        )
      expect(fst.expired?).to be false
    end
  end

  describe "#refresh!" do
    let(:test_token) {
      FeedShareToken.create!(
          token: "bla",
          user: test_user,
          expires_at: Time.current
          )
    }

    it "should regenerate the token" do
      mock_token = "doggy"
      allow(TokenHandlerService)
        .to receive(:generate_token_from_hash)
        .and_return(mock_token)

      test_token.refresh!

      expect(test_token.token).to eq(mock_token)
    end
  end
end
