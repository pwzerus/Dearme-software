class PostTag < ApplicationRecord
  belongs_to :post
  belongs_to :tag

  validate :post_and_tag_creator_matches

  private

  def post_and_tag_creator_matches
    if post.creator_id != tag.creator_id
      errors.add(:base, "Post and tag must belong to the same creator")
    end
  end
end
