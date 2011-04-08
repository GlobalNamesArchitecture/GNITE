require 'spec_helper'

describe TreeSearchesController, 'GET to show search results in master tree' do
  let(:user) { Factory(:email_confirmed_user) }
  let(:master_tree) { Factory(:master_tree, :user => user) }
  let(:node)  { Factory(:node, :tree => master_tree) }
  
  subject { controller }

  before do
    sign_in_as(user)
    get :show, :tree_id => master_tree, :name_string => node.name_string, :format => 'json'
  end
  
  it { should respond_with(:success) }
  
end