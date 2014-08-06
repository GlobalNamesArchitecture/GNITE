require 'spec_helper'

describe GnaclrSearchesController, 'route', :type => :controller do
  it { should route(:get, '/gnaclr_searches').to(:action => 'show') }
end

describe GnaclrSearchesController, 'xhr GET to show', :type => :controller do
  let(:user)           { create(:user) }
  let(:master_tree)    { create(:master_tree, :user_id => user.id) }
  let(:search_results) { File.open('features/support/fixtures/gnaclr_search_result.json') }

  before do
    gnaclr_search_mock = mock('gnaclr_search')
    GnaclrSearch.stubs(:new => gnaclr_search_mock)
    gnaclr_search_mock.stubs(:results => search_results)

    sign_in user

    xhr :get,
        :show,
        :search_term => 'abc',
        :master_tree_id => master_tree.id
  end

  it { should respond_with(:success) }

  it "should assign_to(:master_tree).with(master_tree)" do
    assigns(:master_tree).should == master_tree
  end

  it { should render_template(:show) }
end

describe GnaclrSearchesController, 'xhr GET to show with GNACLR service down', :type => :controller do
  let(:user)           { create(:user) }

  before do
    gnaclr_search_mock = mock('gnaclr_search')
    GnaclrSearch.stubs(:new => gnaclr_search_mock)
    gnaclr_search_mock.stubs(:results).raises(Gnite::ServiceUnavailable)

    sign_in user

    xhr :get,
        :show,
        :search_term => 'abc'
  end

  it 'responds with a 503 status code and empty body' do
    should respond_with :service_unavailable
    response.body.strip.should be_empty
  end
end
