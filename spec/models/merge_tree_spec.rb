require 'spec_helper'

describe MergeTree do
  it { should have_one(:merge_event) }
end
