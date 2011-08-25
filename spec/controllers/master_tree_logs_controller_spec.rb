require 'spec_helper'

describe MasterTreeLogsController, 'GET to show edit history for master tree' do
  let(:user) { Factory(:user) }
  let(:master_tree) { Factory(:master_tree, :user => user) }
  let(:node)  { Factory(:node, :tree => master_tree) }
  
  subject { controller }

  before do
    sign_in user
    get :index, :master_tree_id => master_tree
  end
    
  it { should respond_with(:success) }
  it { should render_template(:master_tree_log) }
end