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
end
