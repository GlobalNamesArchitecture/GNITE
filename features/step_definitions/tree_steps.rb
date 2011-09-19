Given /^"([^"]*)" has created an existing master tree titled "([^"]*)" with:$/ do |user_email, tree_title, table|
  user = User.find_by_email(user_email)
  tree = Factory :master_tree, :title => tree_title, :user_id => user.id, :user => user
  table.raw.each do |row|
    Factory(:node, :name => Factory(:name, :name_string => row.first), :tree => tree)
  end
end

Given /^"([^"]*)" has created an existing master tree titled "([^"]*)" with the following nodes:$/ do |user_email, tree_title, table|
  user = User.find_by_email(user_email)
  tree = Factory :master_tree, :title => tree_title, :user_id => user.id, :user => user
  table.hashes.each do |hash|
    parent = (hash['parent_id'].to_i == 0) ? tree.root.id : hash['parent_id'].to_i
    rank = hash['rank'].nil? ? "Family" : hash['rank']
    node = Factory(:node, :id => hash['id'].to_i, :name => Factory(:name, :name_string => hash['name']), :parent_id => parent, :tree => tree, :rank => rank)
    
    unless hash['synonyms'].nil?
      hash['synonyms'].split(',').each do |synonym|
        Factory(:synonym, :name => Factory(:name, :name_string => synonym.strip), :node => node)
      end
    end

    unless hash['vernacular_names'].nil?
      hash['vernacular_names'].split(',').each do |vernacular_name|
        Factory(:vernacular_name, :name => Factory(:name, :name_string => vernacular_name.strip), :node => node)
      end
    end
  end
end

When /^"([^"]*)" is a contributor to the master tree "([^"]*)"$/ do |email, tree_title|
  user = User.find_by_email(email)
  master_tree = MasterTree.find_by_title(tree_title)
  Factory(:master_tree_contributor, :user => user, :master_tree => master_tree)
end

When /^I refresh the master tree$/ do
  page.execute_script("jQuery('#master-tree').jstree('refresh');")
  sleep 2
end

Then /^the master tree should be locked$/ do
  page.should have_css(".jstree-locked")
end
