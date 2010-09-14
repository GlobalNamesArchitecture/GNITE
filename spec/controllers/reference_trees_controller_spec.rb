require 'spec_helper'

describe ReferenceTreesController, 'html GET show' do

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
      let(:nodes_list) { ["Title One", "Title Two", "Title Three"] }
      before do
        ReferenceTree.stubs(:new => tree)
        post :create, :format => 'json',
                     :reference_tree => {:title => tree.title, :master_tree_id => master_tree.id },
                      :nodes_list => nodes_list
      end

      it "should assign nodes to tree" do
        tree.nodes.map{|node| node.name}.should == ["Title One", "Title Two", "Title Three"]
      end

      it { should respond_with(:success) }

      it "should render the new tree as JSON" do
        response.body.should == tree.to_json
      end
    end
  end
end

describe ReferenceTreesController, 'xhr GET show for a tree that is importing' do
  let(:user) { Factory(:user) }
  let(:reference_tree) { Factory(:reference_tree,
                                :user  => user,
                                :state => 'importing') }
  subject { controller }
  before do
    sign_in_as user
    xhr :get,
        :show,
        :id => reference_tree.id
  end

  it 'responds with a 206 No Content and no layout' do
    should respond_with(:no_content)
    response.body.strip.should be_empty
  end
end

describe ReferenceTreesController, 'xhr GET show for a tree that is active' do
  let(:user) { Factory(:user) }
  let(:reference_tree) { Factory(:reference_tree,
                                :user  => user,
                                :state => 'active') }
  subject { controller }
  before do
    sign_in_as user
    xhr :get,
        :show,
        :id => reference_tree.id

  end

  it 'renders the reference tree' do
    should respond_with(:success)
    should render_template(:reference_tree)
  end
end
