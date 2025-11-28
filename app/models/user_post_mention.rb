class UserPostMention < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validate :creator_cannot_be_mentioned

  private

  def creator_cannot_be_mentioned
    if user_id == post.creator_id
      errors.add(:base,
                 "Post shouldn't be able to mention its own creator, as" \
                 "mentioning is a feature meant for other non creator users")
    end
  end
end
