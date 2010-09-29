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

  #it { should_not render_with_layout }
  it { should render_template(:show) }
  #it { should respond_with(:success) }
end

describe SearchesController, 'html GET to show' do
  before do
    sign_in

    get :show
  end

  #it { should respond_with(:bad_request) }
end
