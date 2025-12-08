class MediaFile < ApplicationRecord
  # Added freeze too as its the correct way to define constants
  # also helped prevent nasty redefinition errors that came if
  # UNKNOWN was added (only IMAGE, VIDEO, AUDIO were present before)
  # and freeze wasn't used. (Another alternative would have been
  # to use ||= instead of = with freeze to avoid redefinition errors)
  module Type
    IMAGE = "image".freeze
    VIDEO = "video".freeze
    AUDIO = "audio".freeze
    UNKNOWN = "unknown".freeze
  end

  # Could be associated directly with a User (e.g. profile picture)
  # or associated directly with a Post
  belongs_to :parent, polymorphic: true

  has_one_attached :file
  validates :file, presence: true

  validates :file_type,
            presence: true,
            inclusion: { in: [
                           Type::IMAGE,
                           Type::VIDEO,
                           Type::AUDIO,
                           Type::UNKNOWN
                         ] }

  # Convenience methods
  def belongs_to_user?
    parent_type == "User"
  end

  def belongs_to_post?
    parent_type == "Post"
  end

  # The writer hasn't encountered similar formats for audio/image
  # where they are not prefixed by audio/image respectively. But
  # if we do in future, similar pattern as done for the videos should
  # be used for them
  VIDEO_MIME_TYPES_WITHOUT_VIDEO_PREFIX = [
      "application/mp4"
  ]

  def self.is_video_content_type?(content_type)
    content_type.starts_with?("video/") ||
           VIDEO_MIME_TYPES_WITHOUT_VIDEO_PREFIX.include?(content_type)
  end

  # Get the MediaFile::Type from the html format content type of
  # a file
  def self.type_from_content_type(content_type)
    if content_type.starts_with?("image/")
      Type::IMAGE
    elsif self.is_video_content_type?(content_type)
      Type::VIDEO
    elsif content_type.starts_with?("audio/")
      Type::AUDIO
    else
      Type::UNKNOWN
    end
  end

  def duplicate_for(new_parent)
    duplicated_media = dup
    duplicated_media.parent = new_parent

    if file.attached?
      duplicated_media.file.attach(
        io: StringIO.new(file.download),
        filename: file.filename.to_s,
        content_type: file.content_type
      )
    end

    duplicated_media.save!
    duplicated_media
  end
end
