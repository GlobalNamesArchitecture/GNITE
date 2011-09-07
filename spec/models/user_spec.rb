require 'spec_helper'

describe User do
  it { should have_many :action_commands }
  it { should have_many :master_trees }
  it { should have_many :master_tree_contributors }
  it { should have_many :master_tree_logs }
  it { should have_many :merge_events }
  it { should have_one :roster }
end
