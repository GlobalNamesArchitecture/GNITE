require 'spec_helper'

describe ReferenceTreesController do

  context "when signed in with a master tree" do
    let(:user) { Factory(:email_confirmed_user) }
    let(:master_tree) { Factory(:master_tree) }

    before do
      sign_in_as(user)

      controller.stubs(:current_user => user)
    end

    subject { controller }

    context "on POST to #create.json" do
      let(:tree) { Factory(:reference_tree, :title => "Awesome title") }
      let(:node_list) { "Title One\nTitle Two\nTitle Three" }
      before do
        ReferenceTree.stubs(:new => tree)
        post :create, :format => 'json',
                     :reference_tree => {:title => tree.title, :master_tree_id => master_tree.id },
                      :node_list => node_list
      end

      it "should assign nodes to tree" do
        tree.nodes.map{|node| node.name}.should == ["Title One", "Title Two", "Title Three"]
      end

      it { should respond_with(:created) }

      it "should render the new tree as JSON" do
        response.body.should == tree.to_json
      end
    end
  end
end
