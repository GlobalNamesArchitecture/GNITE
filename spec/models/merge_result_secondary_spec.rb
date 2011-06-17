require 'spec_helper'

describe MergeResultSecondary do
  it { should belong_to(:merge_result_primary) }
  it { should belong_to(:node) }
  it { should belong_to(:merge_type) }
  it { should belong_to(:merge_subtype) }
  it { should belong_to(:merge_decision) }
end
