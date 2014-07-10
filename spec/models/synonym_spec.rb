require 'spec_helper'

describe Synonym, 'valid' do
  subject { create :synonym }
  it_should_behave_like 'alternate names'
end
