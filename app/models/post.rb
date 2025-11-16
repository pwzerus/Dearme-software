class Post < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  has_many :media_files, as: :parent, dependent: :destroy
end
