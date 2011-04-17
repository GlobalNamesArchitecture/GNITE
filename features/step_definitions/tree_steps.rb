Given /^"([^"]*)" has created an existing master tree titled "([^"]*)" with:$/ do |user_email, tree_title, table|
  user = User.find_by_email(user_email)
  tree = Factory :master_tree, :title => tree_title, :user => user
  table.raw.each do |row|
    Factory(:node, :name => Factory(:name, :name_string => row.first), :tree => tree)
  end
end

When /^I refresh the master tree$/ do
  page.execute_script("jQuery('#master-tree').jstree('refresh');")
  sleep 1
end
