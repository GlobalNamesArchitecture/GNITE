Factory.sequence(:name_string) do |i|
  "name #{i}"
end

Factory.sequence(:string) do |i|
  "string_#{i}"
end

Factory.sequence(:bookmark_title) do |i|
  "bookmark_#{i}"
end

Factory.define :language do |language|
 language.name { Factory.next(:string) }
 language.iso_639_1 { Factory.next(:string) }
 language.iso_639_2 { Factory.next(:string) }
 language.iso_639_3 { Factory.next(:string) }
 language.native { Factory.next(:string) }
end

Factory.define :tree do |tree|
  tree.title { "My Tree" }
  tree.creative_commons { 'cc0' }
end

Factory.define :master_tree, :parent => :tree, :class => 'MasterTree' do |master_tree|
  master_tree.user { Factory(:user) }
end

Factory.define :reference_tree, :parent => :tree, :class => 'ReferenceTree' do |reference_tree|
  reference_tree.revision { Factory.next(:string) }
  reference_tree.publication_date { Time.now }
end

Factory.define :deleted_tree, :parent => :tree, :class => 'DeletedTree' do |deleted_tree|
  deleted_tree.association :master_tree
end

Factory.define :node do |node|
  node.association :tree
  node.association :name
  node.rank { 'Family' }
end

Factory.define :name do |name|
  name.name_string { Factory.next(:name_string) }
end

Factory.define :bookmark do |bookmark|
  bookmark.association :node
  bookmark.node_id { Factory(:node) }
  bookmark.bookmark_title { Factory.next(:bookmark_title) }
end

Factory.define :synonym do |synonym|
  synonym.association :node
  synonym.association :name
  synonym.status { 'synonym' }
end

Factory.define :vernacular_name do |vernacular|
  vernacular.association :node
  vernacular.association :name
  vernacular.association :language
  vernacular.locality { 'United States' }
end

Factory.define :gnaclr_importer do |gnaclr_importer|
  gnaclr_importer.association :reference_tree
  gnaclr_importer.url {'foo'}
end

Factory.define :action_rename_node do |action_rename_node|
  action_rename_node.tree_id { Factory(:master_tree).id }
  action_rename_node.association :user
  action_rename_node.node_id { |a| Factory(:node, :tree_id => a.tree_id ).id }
  action_rename_node.old_name { |a| Node.find(a.node_id).name.name_string }
  action_rename_node.new_name { Factory.next(:name_string) }
end

Factory.define :action_move_node_within_tree do |action_move_node|
  action_move_node.tree_id { Factory(:master_tree).id }
  action_move_node.association :user
  action_move_node.parent_id { |a| Factory(:node, :tree_id => a.tree_id).id }
  action_move_node.node_id { |a| Factory(:node, :parent_id => a.parent_id, :tree_id => a.tree_id).id }
  action_move_node.destination_parent_id {|a| Factory(:node, :tree_id => a.tree_id).id }
end

Factory.define :action_move_node_to_deleted_tree do |action_delete_node|
  action_delete_node.tree_id { Factory(:master_tree).id }
  action_delete_node.association :user
  action_delete_node.parent_id { |a| Factory(:node, :tree_id => a.tree_id).id }
  action_delete_node.node_id { |a| Factory(:node, :parent_id => a.parent_id, :tree_id => a.tree_id).id }
end

Factory.define :action_copy_node_from_another_tree do |action_copy_node|
  action_copy_node.tree_id { Factory(:master_tree).id }
  action_copy_node.association :user
  action_copy_node.node_id { Factory(:node, :tree => Factory(:reference_tree)).id }
  action_copy_node.destination_parent_id { |a| Factory(:node, :tree_id => a.tree_id).id  }
end

Factory.define :action_add_node do |action_add_node|
  action_add_node.tree_id { Factory(:master_tree).id }
  action_add_node.association :user
  action_add_node.parent_id { |a| Factory(:node, :tree_id => a.tree_id).id }
end

Factory.define :action_bulk_add_node do |action_bulk_add_node|
  action_bulk_add_node.tree_id { Factory(:master_tree).id }
  action_bulk_add_node.association :user
  action_bulk_add_node.parent_id { |a| Factory(:node, :tree_id => a.tree_id).id }
  action_bulk_add_node.json_message { {:do => %w(name1 name2 name3)}.to_json }
end

Factory.define :master_tree_contributor do |master_tree_contributor|
  master_tree_contributor.association :user, :factory => :email_confirmed_user
  master_tree_contributor.association :master_tree
end

Factory.define :reference_tree_collection do |reference_tree_collection|
  reference_tree_collection.association :reference_tree
  reference_tree_collection.association :master_tree
end
