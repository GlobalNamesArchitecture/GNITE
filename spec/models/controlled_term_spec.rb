require 'spec_helper'

describe ControlledTerm, 'valid' do
  it { should belong_to :controlled_vocabulary }
end