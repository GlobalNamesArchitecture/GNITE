# encoding: utf-8
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'shoulda'

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods

  config.mock_framework = :mocha
  config.use_transactional_fixtures = true
  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :controller

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, 
                               { except: Gnite::DbData.prepopulated_tables })
    Gnite::DbData.populate
  end

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
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
end

