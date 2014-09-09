source 'http://rubygems.org'

gem 'rails', '~> 4.1'
gem 'mysql2', '~> 0.3'
gem 'devise', '~> 3.2'
gem 'cancancan', '~> 1.9'
gem 'formtastic', '~> 2.2'
gem 'uuid', '~> 2.3'
gem 'crack', '~> 0.4'
gem 'biodiversity19', '~> 0.7'
gem 'dwc-archive', '~> 0.9'
gem 'yajl-ruby', '~> 1.2', require: 'yajl'
gem 'nokogiri', '~> 1.5'
gem 'resque', '~> 1.25'
gem 'rest-client', '~> 1.7'
gem 'juggernaut', '2.1.0'
gem 'will_paginate', '~> 3.0'
gem 'family-reunion', '~> 0.2.4'
gem 'sanitize', '~> 3.0'

group :development do
  gem 'high_voltage', '~> 2.2'
end

group :test, :development, :test_dev do
  gem 'rspec-rails', '~> 3.0'
  gem 'escape_utils', '~> 1.0'
  gem 'byebug', '~> 3.4'
end

group :test do
  gem 'polyglot', '~> 0.3'
  gem 'capybara', '~> 2.4'
  gem 'cucumber', '~> 1.3'
  gem 'cucumber-rails', '~> 1.4', require: false
  gem 'database_cleaner', '~> 1.3'
  gem 'spork', '~> 0.9'
  gem 'launchy', '~> 2.4' # So you can do 'Then show me the page'.
  gem 'mocha', '~> 0.14', require: 'mocha/api'
  gem 'bourne', '~> 1.5'
  gem 'sham_rack', '~> 1.3'
  gem 'sinatra', '~> 1.4', require: false
  gem 'timecop', '~> 0.7'
  gem 'factory_girl_rails', '~> 4.4'
  gem 'shoulda', '~> 3.5'
  gem 'selenium-webdriver', '~> 2.39.0'
end

group :staging do
  gem 'unicorn', '~> 4.8'
end

group :production do
  gem 'thin', '~> 1.6'
  gem 'rack-google_analytics', '~> 1.0', require: 'rack/google_analytics'
end
