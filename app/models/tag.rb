class Tag < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validates :title, presence: true, uniqueness: true
end
