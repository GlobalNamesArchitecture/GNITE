require 'spec_helper'

describe MasterTree do
  it { should be_kind_of(Tree) }
  it { should have_many(:reference_trees) }
end
