require 'spec_helper'

describe ReferenceTree do
  it { should be_kind_of(Tree) }
  it { should belong_to(:master_tree) }
end
