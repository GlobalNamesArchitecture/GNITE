require 'spec_helper'

describe ReferenceTreeCollection do
  it { should validate_presence_of :reference_tree }
  it { should validate_presence_of :master_tree }
end
