class AddUniqueViewerVieweeIndexToUserViewUsers < ActiveRecord::Migration[8.0]
  def change
    add_index :user_view_users, [ :viewer_id, :viewee_id ], unique: true
  end
end
