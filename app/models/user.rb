class User < ApplicationRecord
  # We need to explicitly specify that the foreign key for
  # tags is not user_id (convention) and creator_id instead.
  has_many :tags, foreign_key: :creator_id, dependent: :destroy

  # We need to explicitly specify that the foreign key for
  # posts is not user_id (convention) and creator_id instead.
  has_many :posts, foreign_key: :creator_id, dependent: :destroy
end
