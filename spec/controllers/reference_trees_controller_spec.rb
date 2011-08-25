require 'spec_helper'

describe ReferenceTreesController, 'html POST create' do
  context "when signed in with a master tree" do
    let(:user) { Factory(:user) }
    let(:master_tree) { Factory(:master_tree, :user => user) }

    before do
      sign_in user

      controller.stubs(:current_user => user)
    end

    subject { controller }

    context "on POST to #create.json" do
      let(:tree) { Factory(:reference_tree, :title => "Awesome title") }
      let(:nodes_list) { ["Title One", "Title Two", "Title Three"] }
      before do
        ReferenceTree.stubs(:new => tree)
        post :create, :format         => 'json',
                      :reference_tree => {:title => tree.title, :publication_date => 2.days.ago, :revision => '123abcdef', :master_tree_id => master_tree.id },
                      :nodes_list     => nodes_list
      end

      it "should assign nodes to tree" do
        tree.nodes.map{|node| node.name_string}.should == ["tree_root", "Title One", "Title Two", "Title Three"]
      end

      it { should respond_with(:success) }
      it { should render_template(:reference_tree) }
    end
  end
end

describe ReferenceTreesController, 'POST create without authenticating' do
  before { post :create }
  it     { should redirect_to(new_user_session_url) }
end

describe ReferenceTreesController, 'xhr GET show for a tree that is importing' do
  let(:user) { Factory(:user) }
  let(:reference_tree) { Factory(:reference_tree,
                                :state => 'importing') }
  subject { controller }
  before do
    sign_in user
    get :show,
        :id     => reference_tree.id,
        :format => :json
  end

  it 'responds with a 206 No Content and no layout' do
    should respond_with(:no_content)
    response.body.strip.should be_empty
  end
end

describe ReferenceTreesController, 'xhr GET show for a tree that is active' do
  let(:user) { Factory(:user) }
  let(:reference_tree) { Factory(:reference_tree,
                                :state => 'active') }
  subject { controller }
  before do
    sign_in user
    xhr :get,
        :show,
        :id => reference_tree.id,
        :format => :json

  end

  it { should respond_with(:success) }
  it { should render_template(:reference_tree) }
end

describe ReferenceTreesController, 'html GET to show' do
  let(:user) { Factory(:user) }
  before do
    sign_in user
    get :show, :id => 1
  end

  it { should respond_with(:bad_request) }
end

describe ReferenceTreesController, 'GET show without authenticating' do
  before { get :show, :id => 1 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end
