class AddLocationToPosts < ActiveRecord::Migration[8.0]
  def change
    # allowed to be null (no location tied to a post)
    add_reference :posts, :location, null: true, foreign_key: true
  end
end
