require 'spec_helper'

describe SearchesController, 'route' do
  it { should route(:get, '/search').to(:action => 'show') }
end

describe SearchesController, 'xhr GET to show' do
  let(:user)           { Factory(:email_confirmed_user) }
  let(:master_tree)    { Factory(:master_tree, :user => user) }
  let(:search_results) { File.open('features/support/fixtures/search_result.json') }

  before do
    search_mock = mock('search')
    Search.stubs(:new => search_mock)
    search_mock.stubs(:results => search_results)

    sign_in_as(user)

    xhr :get,
        :show,
        :search_term => 'abc',
        :master_tree_id => master_tree.id
  end

  it { should respond_with(:success) }
  it { should assign_to(:master_tree).with(master_tree) }
  it { should render_template(:show) }
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
