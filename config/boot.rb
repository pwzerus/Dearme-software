require "bundler/setup"
require "dotenv/load" if ENV.fetch("RAILS_ENV", "development") != "production"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
