# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Gnite::Application.initialize!

require 'open-uri'
