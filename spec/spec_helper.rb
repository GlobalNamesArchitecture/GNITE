# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'factory_girl'
Factory.find_definitions
require 'shoulda'

RSpec.configure do |config|
  config.mock_with :mocha
  config.use_transactional_fixtures = true
  config.include SessionHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:suite) do
    Gnite::ResqueHelper.cleanup
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # I imagine something like this would run one time only and not be removed by transaction
  # config.before(:all) do
  #   Language.create(name: "English", iso_639_1: "en", iso_639_2: "eng", iso_639_3: "eng", native: "English")
  #   Language.create(name: "Portuguese", iso_639_1: "pt", iso_639_2: "por", iso_639_3: "por", native: "Portugu?s")
  # end

end
