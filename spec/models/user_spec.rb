require 'spec_helper'

describe User do
  it { should have_many :master_trees }
  it { should have_many :reference_trees }
end
