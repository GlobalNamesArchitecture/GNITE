require 'spec_helper'

describe Bookmark do
  it { should validate_uniqueness_of(:node_id) }

  it { should have_many :nodes }
end