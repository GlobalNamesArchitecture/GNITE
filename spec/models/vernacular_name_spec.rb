require 'spec_helper'

describe VernacularName, 'valid' do
  subject { create :vernacular_name }
  it_should_behave_like 'alternate names'
end
