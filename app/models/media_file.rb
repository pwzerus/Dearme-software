class MediaFile < ApplicationRecord
  module Type
    IMAGE = "image"
    VIDEO = "video"
    AUDIO = "audio"
  end

  # Could be associated directly with a User (e.g. profile picture)
  # or associated directly with a Post
  belongs_to :parent, polymorphic: true

  has_one_attached :file
  validates :file, presence: true

  validates :file_type,
            presence: true,
            inclusion: { in: [ Type::IMAGE, Type::VIDEO, Type::AUDIO ]}

  # Convenience methods
  def belongs_to_user?
    owner_type == "User"
  end

  def belongs_to_post?
    owner_type == "Post"
  end
end
