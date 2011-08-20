$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'family-reunion'
require 'ostruct'
require 'shoulda'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
end

class FamilyReunion
  class Spec
    Config = OpenStruct.new(
      :ants_primary_node => JSON.parse(open(File.join(File.dirname(__FILE__), 'fixtures', 'ants_primary.json')).read, :symbolize_names => true),
      :ants_secondary_node => JSON.parse(open(File.join(File.dirname(__FILE__), 'fixtures', 'ants_secondary.json')).read, :symbolize_names => true),
      :valid_names_primary => JSON.parse(open(File.join(File.dirname(__FILE__), 'fixtures', 'valid_names_strings_primary.json')).read),
      :valid_names_secondary => JSON.parse(open(File.join(File.dirname(__FILE__), 'fixtures', 'valid_names_strings_secondary.json')).read),
      :synonyms_primary => JSON.parse(open(File.join(File.dirname(__FILE__), 'fixtures', 'synonyms_strings_primary.json')).read),
      :synonyms_secondary => JSON.parse(open(File.join(File.dirname(__FILE__), 'fixtures', 'synonyms_strings_secondary.json')).read),
      :nodes_to_match => JSON.parse(open(File.join(File.dirname(__FILE__), 'fixtures', 'nodes_to_match.json')).read, :symbolize_names => true),
      :matched_merges => JSON.parse(open(File.join(File.dirname(__FILE__), 'fixtures', 'matched_merges.json')).read, :symbolize_names => true),
    )
  end
end
