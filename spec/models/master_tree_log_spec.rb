require 'spec_helper'

describe MasterTreeLog, 'valid' do
  it { should belong_to :master_tree }
  it { should belong_to :user }
end