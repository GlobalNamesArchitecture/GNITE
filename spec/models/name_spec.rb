require 'spec_helper'

describe Name, 'valid' do
  subject { Factory(:name) }

  it { should validate_presence_of(:name_string) }
  it { should validate_uniqueness_of(:name_string) }

  it { should have_many :nodes }
end
