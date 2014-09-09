require 'spec_helper'

describe GnaclrImportsController, 'xhr POST create', type: :controller do
  let(:user) { create(:user) }
  let(:master_tree) { create(:master_tree, user_id: user.id) }

  before do
    reference_tree = create(:reference_tree, title: 'NCBI')
    ReferenceTree.stubs(:create!).returns(reference_tree)
    GnaclrImporter.stubs(:create!).returns(create(:gnaclr_importer, reference_tree: reference_tree, url: 'foo'))
    sign_in user
    xhr :post,
        :create,
        title: reference_tree.title,
        publication_date: reference_tree.publication_date,
        revision: rand(100000000000000000000000000).to_s,
        master_tree_id: master_tree.id,
        url: 'foo'
  end

  it 'creates an importing reference tree for the master_tree' do
    master_tree.reference_trees.count.should == 1
    tree = master_tree.reference_trees.first
    tree.master_trees.first.should == master_tree
    tree.title.should == 'NCBI'
  end

  it 'responds with the reference tree id in json' do
    response.body.should == { tree_id: master_tree.reference_trees.first.id }.to_json
  end

  it 'creates a new GNACLR importer' do
    GnaclrImporter.should have_received(:create!).with(reference_tree: master_tree.reference_trees.first, url: 'foo')
  end

end

describe GnaclrImportsController, 'reuse of a tree', type: :controller do
  let(:user) { create(:user) }
  let(:master_tree) { create(:master_tree, user_id: user.id) }
  let(:reference_tree) { create(:reference_tree) }
  let(:gnaclr_importer) { create(:gnaclr_importer, reference_tree: reference_tree, url: 'foo') }

  it 'reuses existing reference tree for the second import of the same classification' do
    GnaclrImporter.stubs(:create!).returns(gnaclr_importer)
    ReferenceTree.stubs(:create!).returns(reference_tree)
    sign_in user
    xhr :post,
        :create,
        title: 'NCBI',
        publication_date: reference_tree.publication_date,
        revision: reference_tree.revision,
        master_tree_id: master_tree.id,
        url: 'foo'
    master_tree.reference_trees.size.should == 1
    ReferenceTreeCollection.count.should == 1
    #reuses existing tree, creates a new collection for new master tree
    xhr :post,
        :create,
        title: 'NCBI',
        master_tree_id: create(:master_tree, user: user).id,
        publication_date: reference_tree.publication_date,
        revision: reference_tree.revision,
        url: 'foo'
    master_tree.reference_trees.size.should == 1
    ReferenceTreeCollection.count.should == 2
    #does not create new collection if master and reference combination exists
    xhr :post,
        :create,
        title: 'NCBI',
        publication_date: reference_tree.publication_date,
        revision: reference_tree.revision,
        master_tree_id: master_tree.id,
        url: 'foo'
    master_tree.reference_trees.size.should == 1
    ReferenceTreeCollection.count.should == 2
  end

end

describe GnaclrImportsController, 'html POST create', type: :controller do
  let(:user) { create(:user) }
  subject { controller }
  before do
    sign_in user
    post :create
  end
  it { should respond_with(:bad_request) }
end
