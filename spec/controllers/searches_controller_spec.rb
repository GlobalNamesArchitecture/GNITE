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
    should respond_with(:success)
    should render_template(:show)
    should_not render_template
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
    should respond_with :service_unavailable
    response.body.strip.should be_empty
  end
end
