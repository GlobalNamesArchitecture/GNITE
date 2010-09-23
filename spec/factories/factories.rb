Factory.sequence(:name_string) do |i|
  "taxon #{i}"
end

Factory.define :master_tree do |tree|
  tree.title { "My Tree" }
  tree.association :user
  tree.creative_commons { 'cc0' }
end

Factory.define :reference_tree do |reference_tree|
  reference_tree.title { "My Tree" }
  reference_tree.association :user
  reference_tree.creative_commons { 'cc0' }
end


Factory.define :tree, :class => 'MasterTree' do |tree|
  tree.title { "My Tree" }
  tree.association :user
  tree.creative_commons { 'cc0' }
end

Factory.define :node do |node|
  node.association :tree
  node.name_id { Factory(:name).id }
end

Factory.define :name do |name|
  name.name_string { Factory.next(:name_string) }
end

Factory.define :synonym do |synonym|
  synonym.association :node
  synonym.association :name
end

Factory.define :vernacular_name do |vernacular|
  vernacular.association :node
  vernacular.association :name
end
