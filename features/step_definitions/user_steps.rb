Given('a user exists with:') do |table|
  # Converts the table into a hash with first column as keys
  # and second column elements as corresponding values
  attrs = table.rows_hash

  User.create!(
          email: attrs["email"],
          first_name: attrs["first_name"],
          last_name: attrs["last_name"]
          )
end
