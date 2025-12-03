class User < ApplicationRecord
  # We need to explicitly specify that the foreign key for
  # tags is not user_id (convention) and creator_id instead.
  has_many :tags, foreign_key: :creator_id, dependent: :destroy

  # We need to explicitly specify that the foreign key for
  # posts is not user_id (convention) and creator_id instead.
  has_many :posts, foreign_key: :creator_id, dependent: :destroy

  # User can have one profile picture
  #
  # TODO: Whoever is working on the profile picture setting should take
  # this up When someone writes
  #
  # MediaFile.create!(parent: john, ...) # image 1
  # MediaFile.create!(parent: john, ...) # image 2
  #
  # Then we should ensure that latest profile picture is associated
  # when we write john.profile_picture and the older one is delted
  # from the DB.
  has_one :profile_picture,
          -> { where(file_type: MediaFile::Type::IMAGE) },
          as: :parent,
          class_name: "MediaFile",
          dependent: :destroy

  has_many :user_post_mentions, dependent: :destroy
  has_many :posts_mentioned_in, through: :user_post_mentions, source: :post

  # Whom is this user viewing (a viewee is the one who is viewed) ?
  #
  # Notice the flip in the foregin key its viewer_id and not viewee_id
  # that's because for those many viewees that I (User) can have they should
  # identify me by the foreign key viewer_id (as I am their viewer)
  #
  # Its similar to post belongs to creator via class name user and
  # inside user we have has_many :posts, foreign_key: :creator_id,
  # dependent: :destroy,
  #
  # i.e that associated post should identify me (we're currently in the user
  # model, so me's the user) by creator_id
  has_many :viewee_user_view_users,
           foreign_key: :viewer_id,
           class_name: "UserViewUser"
  has_many :viewees, through: :viewee_user_view_users, source: :viewee

  # Who are the viewers for this user ?
  # Notice the flip in the foregin key its viewee_id and not viewer_id
  # that's because for those many viewers that I (User) have they should
  # identify me by the foreign key viewee_id (as I am their viewee, i.e.
  # they're viewing me)
  #
  # Its similar to post belongs to creator via class name user and
  # inside user we have has_many :posts, foreign_key: :creator_id,
  # dependent: :destroy,
  #
  # i.e that associated post should identify me (we're currently in the user
  # model, so me's the user) by creator_id
  has_many :viewer_user_view_users,
           foreign_key: :viewee_id,
           class_name: "UserViewUser"
  has_many :viewers, through: :viewer_user_view_users, source: :viewer

  # Do NOT access this directly, e.g.
  # DON'T DO user.internal_feed_share_token, use
  # user.feed_share_token method instead
  has_one :internal_feed_share_token,
          class_name: "FeedShareToken",
          dependent: :destroy

  # Always returns a valid, non expired feed share token
  # (or raises an exception if encounters failure)
  def feed_share_token
    if self.internal_feed_share_token.nil?
      self.internal_feed_share_token = FeedShareToken.generate!(self)
    elsif internal_feed_share_token.expired?
      self.internal_feed_share_token.refresh!
    end

    self.internal_feed_share_token
  end
end
