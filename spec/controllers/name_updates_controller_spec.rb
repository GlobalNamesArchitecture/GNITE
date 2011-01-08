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
    @new_name_string = "renamed name"
    @node = master_tree.nodes.first
  end

  it 'updates the name string' do
    Name.find_by_name_string(@new_name_string).should be_nil
    old_name = @node.name
    post :create,
        :master_tree_id => master_tree.id,
        :node_id        => @node.id,
        :format         => 'json',
        :name           => { :name_string => @new_name_string }
    @node.reload.name.should_not == old_name
    renamed_name = Name.find_by_name_string(@new_name_string)
    renamed_name.should_not be_nil
    @node.name.should == renamed_name
    @node.name_string.should == @new_name_string
    response.code.should == "200"
  end

end
