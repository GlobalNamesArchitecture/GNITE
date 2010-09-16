require 'spec_helper'

describe NameUpdatesController, 'routes' do
  it { should route(:post, '/master_trees/1/nodes/2/name_updates').
        to(:action         => 'create',
           :master_tree_id => 1,
           :node_id        => 2) }
end

describe NameUpdatesController, 'POST to create' do
  let(:user) { Factory(:email_confirmed_user) }
  let(:name) { node.name }
  let(:master_tree) { Factory(:master_tree, :user => user) }
  subject { controller }

  before do
    Factory(:node, :tree => master_tree)
    sign_in_as user
    post :create,
        :master_tree_id => master_tree.id,
        :node_id        => master_tree.nodes.first.id,
        :format         => 'json',
        :name           => { :name_string    => 'new name' }
  end

  it 'updates the name string' do
    master_tree.nodes.first.name.reload.name_string.should == 'new name'
  end

  it { should respond_with(:success) }
end
