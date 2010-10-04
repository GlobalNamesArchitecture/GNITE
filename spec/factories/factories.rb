Factory.sequence(:name_string) do |i|
  "taxon #{i}"
end

Factory.define :tree do |tree|
  tree.title { "My Tree" }
  tree.association      :user, :factory => :email_confirmed_user
  tree.creative_commons { 'cc0' }
end

Factory.define :master_tree, :parent => :tree, :class => 'MasterTree' do |master_tree|
end

Factory.define :reference_tree, :parent => :tree, :class => 'ReferenceTree' do |reference_tree|
  reference_tree.association :master_tree
end

Factory.define :node do |node|
  node.association :tree
  node.association :name
  node.rank { 'Family' }
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
