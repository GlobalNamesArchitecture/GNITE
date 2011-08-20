require File.dirname(__FILE__) + '/helper'

begin
require 'rdoc'

class RdocTest < Test::Unit::TestCase
  def rdoc_app(&block)
    mock_app do
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
    end
    get '/'
  end

  it 'renders inline rdoc strings' do
    rdoc_app { rdoc '= Hiya' }
    assert ok?
    assert_equal "<h1>Hiya</h1>\n", body
  end

  it 'renders .rdoc files in views path' do
    rdoc_app { rdoc :hello }
    assert ok?
    assert_equal "<h1>Hello From RDoc</h1>\n", body
  end

  it "raises error if template not found" do
    mock_app { get('/') { rdoc :no_such_template } }
    assert_raise(Errno::ENOENT) { get('/') }
  end
end
rescue
  warn "#{$!.to_s}: skipping rdoc tests"
end
