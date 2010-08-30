Given /^"([^"]*)" has created an existing master tree titled "([^"]*)" with:$/ do |user_email, tree_title, table|
  user = User.find_by_email(user_email)
  tree = Factory :master_tree, :title => tree_title, :user => user
  table.raw.each do |row|
    Factory :node, :name => row.first, :tree => tree
  end
end
