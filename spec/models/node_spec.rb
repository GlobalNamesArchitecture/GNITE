require 'spec_helper'

describe Node do
  it { should belong_to :tree }
  it { should validate_presence_of :tree_id }
  it { should validate_presence_of :name }
end
