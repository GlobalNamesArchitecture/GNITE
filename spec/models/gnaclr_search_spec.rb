require 'spec_helper'

describe GnaclrSearch do
  it 'initializes with a search term' do
    search = GnaclrSearch.new(:search_term => 'foo')
    search.search_term.should == 'foo'
  end

  it 'escapes the search term' do
    search = GnaclrSearch.new(:search_term => 'foo bar')
    search.search_term.should == 'foo%20bar'
  end

  it 'raises if no search term is provided' do
    lambda { GnaclrSearch.new({}) }.should raise_error ArgumentError
  end
end

describe GnaclrSearch, 'issuing a search' do
  subject { GnaclrSearch.new(:search_term => 'asfd') }

  before do
    response = File.open(Rails.root.join('features', 'support', 'fixtures', 'gnaclr_search_result.json')).read
    domain = URI.parse(Gnite::Config.gnaclr_url).host
    stub_app = ShamRack.at(domain).stub
    stub_app.register_resource("/search?format=json&show_revisions=true&search_term=#{subject.search_term}", response, 'application/json')
  end

  it 'parses the resulting json' do
    subject.results.should be_kind_of Hash

    subject.results['scientific_name_search'].should_not be_empty
    subject.results['vernacular_name_search'].should_not be_empty
    subject.results['classification_metadata_search'].should_not be_empty
  end
end

describe GnaclrSearch, 'when GNACLR search service fails' do
  subject { GnaclrSearch.new(:search_term => 'asdf') }

  before do
    OpenURI.stubs(:open).raises("OpenURI::HTTPError")
  end

  it 'raises ServiceUnavailable when there is an HTTP error' do
    expect { subject.results }.to raise_error(Gnite::ServiceUnavailable)
  end

end
