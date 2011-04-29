Given /^"([^"]*)" has created an existing master tree titled "([^"]*)" with:$/ do |user_email, tree_title, table|
  user = User.find_by_email(user_email)
  tree = Factory :master_tree, :title => tree_title, :user => user
  table.raw.each do |row|
    Factory(:node, :name => Factory(:name, :name_string => row.first), :tree => tree)
  end
end

Given /^"([^"]*)" has created an existing master tree titled "([^"]*)" with the following nodes:$/ do |user_email, tree_title, table|
  user = User.find_by_email(user_email)
  tree = Factory :master_tree, :title => tree_title, :user => user
  table.hashes.each do |hash|
    parent = (hash['parent_id'].to_i == 0) ? tree.root.id : hash['parent_id'].to_i
    Factory(:node, :id => hash['id'].to_i, :name => Factory(:name, :name_string => hash['name']), :parent_id => parent, :tree => tree) 
  end
end

When /^I refresh the master tree$/ do
  sleep 3
  page.execute_script("jQuery('#master-tree').jstree('refresh');")
  sleep 3
end
