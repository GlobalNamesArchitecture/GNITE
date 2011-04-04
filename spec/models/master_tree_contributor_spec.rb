require 'spec_helper'

describe MasterTreeContributor do
  it { should validate_presence_of :user }
  it { should validate_presence_of :master_tree }
end
