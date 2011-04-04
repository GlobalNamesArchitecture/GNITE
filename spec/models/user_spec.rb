require 'spec_helper'

describe User do
  it { should have_many :action_commands }
  it { should have_many :master_tree_contributors }
end
