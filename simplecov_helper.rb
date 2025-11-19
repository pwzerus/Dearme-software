require "simplecov"

# Optional grouping (nice in HTML report)
SimpleCov.start "rails" do
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Views", "app/views"
  add_group "Lib", "lib"
end
