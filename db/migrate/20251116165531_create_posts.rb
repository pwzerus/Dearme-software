class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.references :creator,
                   null: false,
                   foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
