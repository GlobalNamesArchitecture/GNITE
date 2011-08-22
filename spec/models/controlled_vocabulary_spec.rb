require 'spec_helper'

describe ControlledVocabulary do
  it { should have_many(:controlled_terms) }
end