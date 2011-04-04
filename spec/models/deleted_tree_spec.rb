require 'spec_helper'

describe DeletedTree do
  it { should be_kind_of(Tree) }
  it { should belong_to(:master_tree) }

  it 'Should have a title "Deleted Names"' do
    deleted_tree = Factory(:deleted_tree)
    deleted_tree.title.should == 'Deleted Names'
  end
end
