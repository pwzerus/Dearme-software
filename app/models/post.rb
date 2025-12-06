class Post < ApplicationRecord
  belongs_to :creator, class_name: "User"

  # Can be optionally associated with a location
  belongs_to :location, optional: true

  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  has_many :media_files, as: :parent, dependent: :destroy

  # Need for allow_destory: true, because we want to allow destorying media
  # files associated with a post while editing a post.
  #
  # From rails doc:
  # By default you will only be able to set and update attributes on the
  # associated model. If you want to destroy the associated model through
  # the attributes hash, you have to enable it first using the
  # :allow_destroy option.
  #
  # e.g. member.avatar_attributes = { id: '2', _destroy: '1' }
  # to destory the avatar associated with the member
  accepts_nested_attributes_for :media_files, allow_destroy: true

  has_many :user_post_mentions, dependent: :destroy
  has_many :mentioned_users, through: :user_post_mentions, source: :user

  # Create a copy of this post that belongs to the given user.
  #
  # Below are the things we copy as part of duplicate:
  # - title, description, archived, location, tags, media_files
  # and returns the new Post record.
  # The new copies will be started as archived

  def duplicate_for(user)
    Post.transaction do
      copy = dup

      copy.creator = user
      copy.title = build_duplicated_title

      copy.save!

      # Copy tags
      copy.tags = tags

      # Copy media files and reuse the same blobs
      media_files.find_each do |media|
        duplicated_media = copy.media_files.build(
          file_type:   media.file_type,
          description: media.description
        )

        if media.file.attached?
          # Reuse the same blob so storage is not duplicated
          duplicated_media.file.attach(media.file.blob)
        end

        duplicated_media.save!
      end

      copy
    end
  end

  private

  def build_duplicated_title
    base = title.presence || "Post"
    if base.start_with?("Copy of ")
      base
    else
      "Copy of #{base}"
    end
  end
end
