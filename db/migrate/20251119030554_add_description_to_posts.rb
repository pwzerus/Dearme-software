class AddDescriptionToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :description, :string
  end
end
