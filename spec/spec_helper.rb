# encoding: utf-8
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
    csv_dir = File.join(Rails.root.to_s, 'db', 'csv')
    Dir.entries(csv_dir).each do |file|
      next if file[-4..-1] != '.csv'
      table_name = file.gsub(/.csv$/, '')
      ::Node.connection.execute "load data infile '#{File.join(csv_dir, file)}' into table #{table_name} character set utf8"  
    end
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


