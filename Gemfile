source 'http://rubygems.org'

gem 'rails', '3.0.0'
gem 'mysql'
gem 'clearance', '0.9.0.rc9'
gem 'formtastic', '1.1.0'
gem 'engineyard'
gem 'hoptoad_notifier', '2.3.7'
gem 'ancestry', '1.2.1.beta.1', :git => 'git://github.com/thoughtbot/ancestry.git', :branch => 'rails3'
gem 'uuid'
gem 'crack'
gem 'dwc-archive', '0.4.11', :git => 'git://github.com/GlobalNamesArchitecture/dwc-archive.git', :branch => 'master'
gem 'fastercsv'
gem 'parsley-store'
gem 'SystemTimer' # remove for ruby 1.9.x
gem 'yajl-ruby', :require => 'yajl'
gem 'ruby-debug' # change to ruby-debug19 for ruby 1.9.x
gem 'nokogiri'
gem 'resque', '1.10.0'

group :development do
  gem 'high_voltage'
end

group :test, :development do
  gem 'rspec-rails', '2.0.1'
end

group :test do
  gem 'polyglot'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'bourne'
  gem 'spork'
  gem 'launchy' # So you can do "Then show me the page".
  gem 'mocha'
  gem 'bourne'
  gem 'sham_rack'
  gem 'sinatra', :require => false
  gem 'timecop'
  gem 'factory_girl'
  gem 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git'
end

group :staging do
  gem 'unicorn'
end
