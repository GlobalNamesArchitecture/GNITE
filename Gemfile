source 'http://rubygems.org'

gem 'rails', '3.2.19'
gem 'mysql2'
gem 'devise'
gem 'cancan'
gem 'formtastic'
gem 'uuid'
gem 'crack'
gem 'biodiversity19'
gem 'dwc-archive'
# gem 'fastercsv' #remove for ruby 1.9.x
# gem 'SystemTimer' # remove for ruby 1.9.x
gem 'yajl-ruby', :require => 'yajl'
gem 'debugger'
gem 'nokogiri'
gem 'resque'
gem 'rest-client'
gem 'juggernaut'
gem 'will_paginate'
gem 'family-reunion'
gem 'sanitize'

group :development do
  gem 'high_voltage'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.14.2'
  gem "escape_utils"
end

group :test do
  gem 'polyglot'
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'spork'
  gem 'launchy' # So you can do "Then show me the page".
  gem 'mocha'
  gem 'bourne'
  gem 'sham_rack'
  gem 'sinatra', :require => false
  gem 'timecop'
  gem 'factory_girl_rails'
  gem 'shoulda', '3.5.0'
  gem "selenium-webdriver", "~> 2.39.0"
end

group :staging do
  gem 'unicorn'
end

group :production do
  gem 'thin'
  gem 'rack-google_analytics', '1.0.1', :require => "rack/google_analytics"
end
