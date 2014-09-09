require 'spec_helper'

describe MasterTreeLogsController, 'GET to show edit history for master tree', type: :controller do
  let(:user) { create(:user) }
  let(:master_tree) { create(:master_tree, user: user) }
  let(:node)  { create(:node, tree: master_tree) }
  
  subject { controller }

  before do
    sign_in user
    get :index, master_tree_id: master_tree
  end
    
  it { should respond_with(:success) }
  it { should render_template("master_tree_logs/index") }
end