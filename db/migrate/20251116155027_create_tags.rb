class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :title, null: false
      t.references :creator,
                   null: false,
                   foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tags, :title, unique: true
  end
end
