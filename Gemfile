source 'http://rubygems.org'

gem 'rails', '3.1.0'
gem 'mysql2', '0.2.6'
gem 'devise', '1.4.4'
gem 'cancan', '1.6.5'
gem 'formtastic', '1.1.0'
gem 'engineyard'
gem 'hoptoad_notifier', '2.3.7'
# gem 'ancestry', '1.2.1.beta.1', :path => "vendor/git/ancestry", :branch => 'rails3'
gem 'uuid'
gem 'crack'
gem 'biodiversity19'
gem 'dwc-archive', '0.5.15'
# gem 'fastercsv' #remove for ruby 1.9.x
gem 'parsley-store', '0.2.2'
# gem 'SystemTimer' # remove for ruby 1.9.x
gem 'yajl-ruby', :require => 'yajl'
gem 'ruby-debug19' # change to ruby-debug19 for ruby 1.9.x
gem 'nokogiri'
gem 'resque', '1.16.1'
gem 'rest-client', '1.6.1'
gem 'juggernaut', '2.0.1'
gem 'will_paginate', '3.0'
gem 'family-reunion', '0.2.4'
gem 'sanitize', '2.0.3'
gem 'supermodel', '0.1.6'

group :development do
  gem 'high_voltage'
end

group :test, :development do
  gem 'rspec-rails', '2.6.1'
  gem "escape_utils"
end

group :test do
  gem 'polyglot'
  gem 'capybara', '1.0.1'
  gem 'cucumber', '1.0.0'
  gem 'cucumber-rails', '1.0.0'
  gem 'database_cleaner'
  gem 'bourne'
  gem 'spork'
  gem 'launchy' # So you can do "Then show me the page".
  gem 'mocha'
  gem 'bourne'
  gem 'sham_rack'
  gem 'sinatra', :require => false
  gem 'timecop'
  gem 'factory_girl'
  gem 'shoulda', :path => "vendor/git/shoulda"
end

group :staging do
  gem 'unicorn'
end

group :production do
  gem 'thin'
  gem 'rack-google_analytics', '1.0.1', :require => "rack/google_analytics"
end
