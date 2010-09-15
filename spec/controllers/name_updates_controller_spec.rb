require 'spec_helper'

describe NameUpdatesController, 'routes' do
  it { should route(:post, '/master_trees/1/nodes/2/name_updates').
        to(:action         => 'create',
           :master_tree_id => 1,
           :node_id        => 2) }
end

describe NameUpdatesController, 'POST to create' do
  let(:node) { Factory(:node) }
  let(:name) { node.name }
  let(:master_tree) { Factory(:master_tree, :nodes => [node]) }
  subject { controller }

  before do
    post :create,
        :master_tree_id => node.tree.id,
        :node_id        => node.id,
        :format         => 'json',
        :name           => { :name_string    => 'new name' }
  end

  it 'updates the name string' do
    name.reload.name_string.should == 'new name'
  end

  it { should respond_with(:success) }
end
