# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

require 'factory_girl'
Factory.find_definitions

require 'shoulda'

RSpec.configure do |config|
  config.mock_with :mocha
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  #TODO: Extract
  def sign_in_as(user)
    @controller.current_user = user
    return user
  end

  def sign_in
    sign_in_as Factory(:email_confirmed_user)
  end

  def sign_out
    @controller.current_user = nil
  end
end
