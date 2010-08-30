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


Factory.define :tree do |tree|
  tree.title { "My Tree" }
  tree.association :user
  tree.creative_commons { 'cc0' }
end

Factory.sequence :node_name do |n|
  "Node #{n}"
end

Factory.define :node do |node|
  node.association :tree
  node.name { Factory.next(:node_name) }
end
