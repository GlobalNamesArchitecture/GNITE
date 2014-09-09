require 'spec_helper'

describe ReferenceTreesController, 'html POST create', type: :controller do
  context "when signed in with a master tree" do
    let(:user) { create(:user) }
    let(:master_tree) { create(:master_tree, user: user) }

    before do
      sign_in user
      controller.stubs(current_user: user)
    end

    subject { controller }

    context "on POST to #create.json" do
      let(:tree) { create(:reference_tree, title: "Awesome title") }
      let(:nodes_list) { ["Title One", "Title Two", "Title Three"] }
      before do
        ReferenceTree.stubs(new: tree)
        post :create, format: 'json',
                      reference_tree: {title: tree.title, publication_date: 2.days.ago, revision: '123abcdef', master_tree_id: master_tree.id },
                      nodes_list: nodes_list
      end

      it "should assign nodes to tree" do
        tree.nodes.map{|node| node.name_string}.should == ["tree_root", "Title One", "Title Two", "Title Three"]
      end

      it { should respond_with(:success) }
      it { should render_template('reference_trees/_reference_tree') }
    end
  end
end

describe ReferenceTreesController, 'POST create without authenticating', type: :controller do
  before { post :create }
  it     { should redirect_to(new_user_session_url) }
end

describe ReferenceTreesController, 'html DELETE destroy', type: :controller do
  context "when signed in with a master tree" do
    let(:user) { create(:user) }
    let(:master_tree) { create(:master_tree, user: user) }
    let(:reference_tree) { create(:reference_tree) }
    let(:reference_tree_collection) { create(:reference_tree_collection, reference_tree: reference_tree, master_tree: master_tree) }
    let(:node) { create(:node, tree: reference_tree) }

    before do
      sign_in user
      controller.stubs(current_user: user)
    end

    subject { controller }

    context "on DELETE to #destroy.json" do
      before do
        master_tree.stubs(save: true)
        reference_tree.stubs(save: true)
        reference_tree_collection.stubs(save: true)
        ::Node.stubs(new: node)
        node.stubs(save: true)
        delete :destroy, format: 'json',
                         id: reference_tree.id,
                         master_tree_id: master_tree.id
      end
      
      it { should respond_with(:success) }
      
      it "should destroy reference_tree" do
        ReferenceTree.count.should == 0
      end
      
      it "should destroy reference_tree_collection" do
        ReferenceTreeCollection.count.should == 0
      end
      
      it "should destroy reference_tree nodes" do
        Node.where(tree_id: reference_tree.id).count.should == 0
      end
    end

    context "on DELETE to #destroy.json" do
      let(:master_tree2) { create(:master_tree, user: user) }
      let(:reference_tree_collection2) { create(:reference_tree_collection, reference_tree: reference_tree, master_tree: master_tree2) }
      before do
        master_tree.stubs(save: true)
        master_tree2.stubs(save: true)
        reference_tree.stubs(save: true)
        reference_tree_collection.stubs(save: true)
        reference_tree_collection2.stubs(save: true)
        ::Node.stubs(new: node)
        node.stubs(save: true)
        delete :destroy, format: 'json',
                         id: reference_tree.id,
                         master_tree_id: master_tree.id
      end
      
      it { should respond_with(:success) }

      it "should NOT destroy reference_tree" do
        ReferenceTree.count.should == 1
      end
      
      it "should NOT destroy reference_tree nodes" do
        Node.count(conditions: "tree_id = #{reference_tree.id}").should be > 0
      end
      
      it "should destroy reference_tree_collection" do
        ReferenceTreeCollection.count.should == 1
      end

    end
    
  end
end

describe ReferenceTreesController, 'DELETE destroy without authenticating', type: :controller do
  let(:reference_tree) { create(:reference_tree) }
  
  before { delete :destroy, id: reference_tree.id }
  it { should redirect_to(new_user_session_url) }
end

describe ReferenceTreesController, 'xhr GET show for a tree that is importing', type: :controller do
  let(:user) { create(:user) }
  let(:reference_tree) { create(:reference_tree,
                                state: 'importing') }
  subject { controller }
  before do
    sign_in user
    get :show,
        id: reference_tree.id,
        format: :json
  end

  it 'responds with a 206 No Content and no layout' do
    should respond_with(:no_content)
    response.body.strip.should be_empty
  end
end

describe ReferenceTreesController, 'xhr GET show for a tree that is active', type: :controller do
  let(:user) { create(:user) }
  let(:reference_tree) { create(:reference_tree, state: 'active') }
  
  subject { controller }
  before do
    sign_in user
    xhr :get,
        :show,
        id: reference_tree.id,
        format: :json

  end

  it { should respond_with(:success) }
  it { should render_template('reference_trees/_reference_tree') }
end

describe ReferenceTreesController, 'html GET to show', type: :controller do
  let(:user) { create(:user) }
  let(:reference_tree) { create(:reference_tree) }
  
  before do
    sign_in user
    get :show, id: reference_tree.id
  end

  it { should respond_with(:bad_request) }
end

describe ReferenceTreesController, 'GET show without authenticating', type: :controller do
  let(:reference_tree) { create(:reference_tree) }
  
  before { get :show, id: 1 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end
