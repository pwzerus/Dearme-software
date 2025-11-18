class AddArchivedToPosts < ActiveRecord::Migration[8.0]
  def change
    # A created post is archived by default
    add_column :posts, :archived, :boolean, default: true
  end
end
