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
end
