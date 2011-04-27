source 'http://rubygems.org'

gem 'rails', '3.0.1'
gem 'mysql2'
gem 'clearance', '0.9.0.rc9'
gem 'formtastic', '1.1.0'
gem 'engineyard'
gem 'hoptoad_notifier', '2.3.7'
# gem 'ancestry', '1.2.1.beta.1', :path => "vendor/git/ancestry", :branch => 'rails3'
gem 'uuid'
gem 'crack'
gem 'biodiversity19'
gem 'dwc-archive', '0.5.13'
# gem 'fastercsv' #remove for ruby 1.9.x
gem 'parsley-store', '0.2.2'
# gem 'SystemTimer' # remove for ruby 1.9.x
gem 'yajl-ruby', :require => 'yajl'
gem 'ruby-debug19' # change to ruby-debug19 for ruby 1.9.x
gem 'nokogiri'
gem 'resque', '1.10.0'
gem 'rest-client', '1.6.1'
gem 'juggernaut', '2.0.1'

group :development do
  gem 'high_voltage'
end

group :test, :development do
  gem 'rspec-rails', '2.0.1'
  gem "escape_utils"
end

group :test do
  gem 'polyglot'
  gem 'capybara', '0.4.1.2'
  gem 'database_cleaner'
  gem 'cucumber', '0.9.0'
  gem 'cucumber-rails', '0.3.2'
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
end
