class CreateUserViewUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :user_view_users do |t|
      t.references :viewer, null: false, foreign_key: { to_table: :users }
      t.references :viewee, null: false, foreign_key: { to_table: :users }

      # null when record never expires, i.e. an expiry date is not
      # set
      t.datetime :expires_at, null: true

      t.timestamps
    end
  end
end
