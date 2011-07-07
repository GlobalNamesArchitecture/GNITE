require 'net/http'
require 'uri'

Dir[Rails.root.join("lib", "gnite", "*.rb")].each {|f| require f}

module Gnite
end


