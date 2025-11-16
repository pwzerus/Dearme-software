class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :address_line_1
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country

      t.timestamps
    end
  end
end
