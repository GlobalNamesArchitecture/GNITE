require 'spec_helper'

describe Name, 'valid' do
  subject { Factory(:name) }

  it { should validate_presence_of(:name_string) }
  it { should validate_uniqueness_of(:name_string) }

  it { should have_many :nodes }
end

describe Name, 'knows if it is used in only one tree' do
  subject { Factory(:name) }

  before do
    Factory(:node, :name => subject)
  end

  it 'returns true if the name is used in only one tree' do
    should be_used_only_once
  end

  it 'returns false if the name is used in more than one tree' do
    Factory(:node, :name => subject)
    should_not be_used_only_once
  end

  it 'returns false if the name is used twice in one tree' do
    Factory(:tree, :nodes => [Factory(:node, :name => (subject))])
    should_not be_used_only_once
  end
end

describe Name, 'name_string!' do
  subject { Factory(:name) }

  it 'updates its name_string' do
    subject.name_string!('foo')
    subject.reload
    subject.name_string.should == 'foo'
  end
end
