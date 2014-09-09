shared_examples_for 'alternate names' do
  it { should belong_to :name }
  it { should belong_to :node }

  it 'should validate uniqueness of name scoped to node' do
    new_instance = subject.class.new(name_id: subject.name_id, node_id: subject.node_id)
    new_instance.should_not be_valid

    new_instance.errors[:name_id].should include("has already been taken")
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:node) }
end
