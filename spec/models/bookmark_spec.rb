require 'spec_helper'

describe Bookmark, 'valid' do
  it { should belong_to :node }
  it { should validate_presence_of :node_id }
end