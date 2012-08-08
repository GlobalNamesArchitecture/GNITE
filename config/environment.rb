# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Gnite::Application.initialize!

# Rails 3.0.0.beta4 fix
# https://rails.lighthouseapp.com/projects/8994/tickets/4925-rails-3-to_json-incompatible-with-json-core-library
# class Array
#   def to_json(*a)
#     ActiveSupport::JSON.encode(self)
#   end
# end

require 'open-uri'
