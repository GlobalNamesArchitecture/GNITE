require 'spec_helper'

describe Search do
  it 'initializes with a search term' do
    search = Search.new(:search_term => 'foo')
    search.search_term.should == 'foo'
  end

  it 'escapes the search term' do
    search = Search.new(:search_term => 'foo bar')
    search.search_term.should == 'foo%20bar'
  end

  it 'raises if no search term is provided' do
    lambda { Search.new({}) }.should raise_error ArgumentError
  end
end

describe Search, 'issuing a search' do
  subject { Search.new(:search_term => 'asfd') }

  before do
    response = File.open(Rails.root.join('features', 'support', 'fixtures', 'search_result.json')).read
    stub_app = ShamRack.at(Search::URL).stub
    stub_app.register_resource("/search?format=json&show_revisions=true&search_term=#{subject.search_term}", response, 'application/json')
  end

  it 'parses the resulting json' do
    subject.results.should be_kind_of Hash

    subject.results['scientific_name_search'].should_not be_empty
    subject.results['vernacular_name_search'].should_not be_empty
    subject.results['classification_metadata_search'].should_not be_empty
  end
end

