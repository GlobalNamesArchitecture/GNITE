require 'spec_helper'

describe TreeSearchesController, 'GET to show search results in master tree' do
  let(:user) { Factory(:user) }
  let(:master_tree) { Factory(:master_tree, :user => user) }
  let(:parent)  { Factory(:node, :tree => master_tree) }
  let(:child) { Factory(:node, :parent => parent, :tree => master_tree) }
  
  subject { controller }

  before do
    sign_in user
    get :show, :tree_id => master_tree.id, :name_string => child.name_string
  end
  
  it { should respond_with(:success) }
  it { should render_template(:tree_search) }

end

describe TreeSearchesController, 'GET to show search results in reference tree' do
  let(:user) { Factory(:user) }
  let(:reference_tree) { Factory(:reference_tree) }
  let(:parent)  { Factory(:node, :tree => reference_tree) }
  let(:child) { Factory(:node, :parent => parent, :tree => reference_tree) }
  
  subject { controller }

  before do
    sign_in user
    get :show, :tree_id => reference_tree.id, :name_string => child.name_string
  end
  
  it { should respond_with(:success) }
  it { should render_template(:tree_search) }
 
end

describe TreeSearchesController, 'GET search in master tree without authenticating' do
  before { get :show, :tree_id => 123, :name_string => 'gnite' }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end