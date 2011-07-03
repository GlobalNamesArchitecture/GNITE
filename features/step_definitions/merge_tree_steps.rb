require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec", "spec_helper"))

Given /^"([^"]*)" has created a master tree "([^"]*)" and a reference tree "([^"]*)"$/ do |user_email,master_tree_title,reference_tree_title|
  user = User.find_by_email(user_email)
  master_tree = get_master_tree1({:title => master_tree_title, :user => user})
  
  tree = get_master_tree2({:title => reference_tree_title, :user => user})
  tree.type = "ReferenceTree"
  tree.save
  
  reference_tree = ReferenceTree.find_by_title(reference_tree_title)
  ReferenceTreeCollection.create!(:master_tree => master_tree, :reference_tree => reference_tree)
  reference_tree.reload
end
