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

Factory.define :deleted_tree, :parent => :tree, :class => "DeletedTree" do |deleted_tree|
  deleted_tree.title { "Deleted Names" }
  deleted_tree.association :master_tree
  # deleted_tree.user { deleted_tree.master_tree.user }
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

Factory.define :gnaclr_importer do |gnaclr_importer|
  gnaclr_importer.association :reference_tree
  gnaclr_importer.url {'foo'}
end
