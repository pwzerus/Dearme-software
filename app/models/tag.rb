class Tag < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :title, presence: true, uniqueness: true
end
