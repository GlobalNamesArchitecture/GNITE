$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'parsley-store'
require 'spec'
require 'spec/autorun'

puts "You need to start Redis server on your machine"

Spec::Runner.configure do |config|
  
end
