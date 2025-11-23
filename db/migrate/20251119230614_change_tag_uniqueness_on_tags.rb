class ChangeTagUniquenessOnTags < ActiveRecord::Migration[8.0]
  def change
    # Remove any existing unique index on title alone (if it exists)
    remove_index :tags, :title, if_exists: true

    # Add a composite unique index on [creator_id, title]
    add_index :tags, [ :creator_id, :title ], unique: true
  end
end
