require 'spec_helper'

describe GnaclrImportsController, 'xhr POST create' do
  let(:user) { Factory(:user) }
  let(:master_tree) { Factory(:master_tree, :user => user) }
  before do
    GnaclrImporter.stubs(:new)

    sign_in_as user

    xhr :post,
        :create,
        :title          => 'NCBI',
        :master_tree_id => master_tree.id,
        :url            => 'foo'
  end

  it 'creates an importing reference tree for the current user' do
    user.reference_trees.count.should == 1

    tree = user.reference_trees.first
    tree.should be_importing
    tree.master_tree.should == master_tree
    tree.title.should == 'NCBI'
  end

  it 'reponds with the reference tree id in json' do
    response.body.should == { :tree_id => user.reference_trees.first.id }.to_json
  end

  it 'creates a new GNACLR importer' do
    GnaclrImporter.should have_received(:new).with(:reference_tree => user.reference_trees.first,
                                                   :url            => 'foo')
  end
end

describe GnaclrImportsController, 'html POST create' do
  let(:user) { Factory(:user) }
  subject { controller }
  before do
    sign_in_as user
    post :create
  end
  it { should respond_with(:bad_request) }
end
