FactoryGirl.define do

  sequence :name_string do |i|
    "name #{i}"
  end

  sequence :string do |i|
    "string_#{i}"
  end

  sequence :bookmark_title  do |i|
    "bookmark_#{i}"
  end

  factory :language do
    name { FactoryGirl.generate(:string) }
    iso_639_1 { FactoryGirl.generate(:string) }
    iso_639_2 { FactoryGirl.generate(:string) }
    iso_639_3 { FactoryGirl.generate(:string) }
    native { FactoryGirl.generate(:string) }
  end

  factory :tree do
    title 'My Tree'
    creative_commons 'cc0'
  end

  factory :master_tree, parent: :tree, class: MasterTree do
    association :user
    user_id { FactoryGirl.create(:user) }
  end

  factory :reference_tree, parent: :tree, class: ReferenceTree do
    revision { FactoryGirl.generate(:string) }
    publication_date { Time.now }
  end

  factory :deleted_tree, parent: :tree, class: DeletedTree do
    association :master_tree
  end

  factory :node do
    association :tree
    association :name
    rank 'Family'
  end

  factory :name do
    name_string { FactoryGirl.generate(:name_string) }
  end

  factory :bookmark do
    association :node
    node_id { FactoryGirl.create(:node) }
    bookmark_title { FactoryGirl.generate(:bookmark_title) }
  end

  factory :synonym do
    association :node
    association :name
    status { 'synonym' }
  end

  factory :vernacular_name do
    association :node
    association :name
    association :language
    locality { 'United States' }
  end

  factory :gnaclr_importer do
    association :reference_tree
    url {'foo'}
  end

  factory :master_tree_contributor do
    association :user
    association :master_tree
  end

  factory :reference_tree_collection do
    association :reference_tree
    association :master_tree
  end

  factory :action_rename_node do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    node_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id ).id }
    old_name { |a| Node.find(a.node_id).name.name_string }
    new_name { FactoryGirl.generate(:name_string) }
  end

  factory :action_move_node_within_tree do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    parent_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id).id }
    node_id { |a| FactoryGirl.create(:node, parent_id: a.parent_id, tree_id: a.tree_id).id }
    destination_parent_id {|a| FactoryGirl.create(:node, tree_id: a.tree_id).id }
  end

  factory :action_move_node_to_deleted_tree do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    parent_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id).id }
    node_id { |a| FactoryGirl.create(:node, parent_id: a.parent_id, tree_id: a.tree_id).id }
  end

  factory :action_copy_node_from_another_tree do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    node_id { FactoryGirl.create(:node, tree: FactoryGirl.create(:reference_tree)).id }
    destination_parent_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id).id  }
  end

  factory :action_add_node do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    parent_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id).id }
  end

  factory :action_change_rank do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    node_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id, rank: "species" ).id }
    json_message { {do: "subpecies"}.to_json }
  end

  factory :action_bulk_add_node do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    parent_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id).id }
    json_message { {do: %w(name1 name2 name3)}.to_json }
  end

  factory :action_bulk_copy_node do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    destination_parent_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id).id }
    json_message { {do: nil}.to_json }
  end

  factory :action_node_to_synonym do
    tree_id { FactoryGirl.create(:master_tree).id }
    association :user
    node_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id).id }
    destination_node_id { |a| FactoryGirl.create(:node, tree_id: a.tree_id).id }
    json_message { {do: nil, undo: nil}.to_json }
  end

end