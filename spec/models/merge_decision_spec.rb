require 'spec_helper'

describe MergeDecision do
  it { should have_many(:merge_result_secondaries) }

  it "should have method corresponding to its data" do
    MergeDecision.accepted.label.should  == 'accepted'
    MergeDecision.rejected.label.should  == 'rejected'
    MergeDecision.postponed.label.should == 'postponed'
  end
end
