require 'spec_helper'

describe Tree do
  it { should validate_presence_of :title }
  it { should belong_to :user }
  it { should validate_presence_of :user_id }
  it { should have_many(:nodes) }
end
