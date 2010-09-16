source 'http://rubygems.org'

gem 'rails', '3.0.0.beta4'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql'
gem 'clearance', "0.9.0.rc5"
gem 'factory_girl'
gem 'formtastic', "1.1.0"
gem 'engineyard'
gem 'hoptoad_notifier', '2.3.7'
gem 'ancestry', :git => "git://github.com/thoughtbot/ancestry.git", :branch => "rails3"
gem 'uuid'
gem 'crack'
gem 'delayed_job'
gem 'dwc-archive', '0.4.5'
gem 'fastercsv'
gem 'parsley-store'
gem 'SystemTimer'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri', '1.4.1'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for certain environments:
# gem 'rspec', :group => :test
group :development do
  # # rspec-rails is in the development group to get the rspec rake tasks.
  # # see http://blog.davidchelimsky.net/2010/07/11/rspec-rails-2-generators-and-rake-tasks-part-ii/
  # gem 'rspec-rails', "2.0.0.beta.19"
  gem 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git'
  gem 'rspec-rails', "2.0.0.beta.19"
  gem 'high_voltage'
end

group :test do
  gem 'polyglot'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'rspec-rails', "2.0.0.beta.19"
  gem 'bourne'
  gem 'spork'
  gem 'launchy'    # So you can do Then show me the page
  gem 'mocha'
  gem 'bourne'
  gem 'sham_rack'
  gem 'sinatra'
end

group :staging do
  # Use unicorn as the web server
  gem 'unicorn'
end

