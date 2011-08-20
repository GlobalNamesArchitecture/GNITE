def add_to_load_path(path, prepend=false)
  path = File.expand_path("../#{path}", __FILE__)
  if prepend
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  else
    $LOAD_PATH << path unless $LOAD_PATH.include?(path)
  end
end

add_to_load_path("../lib", :prepend)
add_to_load_path("../../rspec-core/lib")
add_to_load_path("../../rspec-mocks/lib")

require 'rspec/core'
require 'rspec/mocks'

Dir['./spec/support/**/*'].each do |f|
  require f
end

def with_ruby(version)
  yield if RUBY_PLATFORM =~ Regexp.compile("^#{version}")
end

module RSpec
  module Ruby
    class << self
      def version
        RUBY_VERSION
      end
    end
  end
end

module RSpec  
  module Matchers
    def fail
      raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    def fail_with(message)
      raise_error(RSpec::Expectations::ExpectationNotMetError, message)
    end
  end
end

RSpec::configure do |config|
  config.mock_with(:rspec)
  config.include RSpec::Mocks::Methods
  config.color_enabled = true
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
end
