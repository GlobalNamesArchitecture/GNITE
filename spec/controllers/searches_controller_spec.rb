require 'spec_helper'

describe SearchesController, 'route' do
  it { should route(:get, '/search').to(:action => 'show') }
end

describe SearchesController, 'xhr GET to show' do
  let(:search_results) { File.open('features/support/fixtures/search_result.json') }
  before do
    search_mock = mock('search')
    Search.stubs(:new => search_mock)
    search_mock.stubs(:results => search_results)

    sign_in

    xhr :get,
        :show,
        :search_term => 'abc'
  end

  it 'responds with the :show template' do
    should render_template(:show)
    response.code.should == "200"
  end
end

describe SearchesController, 'xhr GET to show with GNACLR service down' do
  before do
    search_mock = mock('search')
    Search.stubs(:new => search_mock)
    search_mock.stubs(:results).raises(Search::ServiceUnavailable)

    sign_in

    xhr :get,
        :show,
        :search_term => 'abc'
  end

  it 'responds with a 503 status code and empty body' do
    response.code.should == "503"
    response.body.strip.should be_empty
  end
end
