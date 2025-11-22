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
            inclusion: { in: [ Type::IMAGE, Type::VIDEO, Type::AUDIO ] }

  # Convenience methods
  def belongs_to_user?
    parent_type == "User"
  end

  def belongs_to_post?
    parent_type == "Post"
  end

  # Get the MediaFile::Type from the html format content type of
  # a file
  def self.type_from_content_type(content_type)
    if content_type.starts_with?("image/")
      Type::IMAGE
    elsif content_type.starts_with?("video/")
      Type::VIDEO
    elsif content_type.starts_with?("audio/")
      Type::AUDIO
    else
      raise ArgumentError, "Unknown content type: #{content_type}"
    end
  end
end
