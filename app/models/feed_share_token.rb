class FeedShareToken < ApplicationRecord
  TIME_TO_LIVE = 1.hour

  belongs_to :user

  validates :token, :expires_at, presence: true

  def self.generate!(user)
    token_info = self.generate_token_helper(user)
    FeedShareToken.create!(
            user: user,
            token: token_info[:token],
            expires_at: token_info[:expires_at]
            )
  end

  # Is the token expired ?
  def expired?
    self.expires_at < Time.current
  end

  # Regenerate the token
  def refresh!
    token_info = self.class.generate_token_helper(self.user)
    self.update!(
      token: token_info[:token],
      expires_at: token_info[:expires_at]
      )
  end

  # Input: user to generate token for
  # Output: a hash of format
  # {
  #   token: String object,
  #   expires_at: Time object
  # }
  #
  # NOTE: Apparently, a private class method does not cooperate well
  # with an instance method (e.g. can't write self.class.method if
  # the method is declared using private_class_method, hence its not
  # declared using that (even though this method should not
  # be used outside this class as its for internal use only)
  def self.generate_token_helper(user)
    new_expires_at = Time.current + TIME_TO_LIVE

    hash = {
      user_id: user.id,
      expires_at: new_expires_at
    }

    {
      token: TokenHandlerService.generate_token_from_hash(hash),
      expires_at: new_expires_at
    }
  end
end
