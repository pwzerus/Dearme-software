class CreateMediaFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :media_files do |t|
      t.references :parent, polymorphic: true, null: false

      t.string :file_type, null: false
      t.string :description

      t.timestamps
    end
  end
end
