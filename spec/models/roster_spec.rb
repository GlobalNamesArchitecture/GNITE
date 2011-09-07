require 'spec_helper'

describe Roster, 'valid' do
  it { should belong_to :user }
  it { should belong_to :master_tree }
end