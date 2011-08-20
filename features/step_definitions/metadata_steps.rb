Then /^I should see "([^"]*)" as synonyms for the "([^"]*)" tree$/ do |synonyms, tree_title|
  tree = Tree.find_by_title!(tree_title)
  id   = tree.type == 'MasterTree' ? 'add-node-wrap +' : "reference_tree_#{tree.id}"

  synonyms.split(',').each do |synonym|
    page.should have_css("##{id} .node-metadata .metadata-synonyms ul li:contains('#{synonym.strip}')")
  end
end

Then /^I should see "([^"]*)" as vernacular names for the "([^"]*)" tree$/ do |vernacular_names, tree_title|
  tree = Tree.find_by_title!(tree_title)
  id   = tree.type == 'MasterTree' ? 'add-node-wrap +' : "reference_tree_#{tree.id}"

  vernacular_names.split(',').each do |vernacular_name|
    page.should have_css("##{id} .node-metadata .metadata-vernacular-names ul li:contains('#{vernacular_name.strip}')")
  end
end

Then /^I should see "([^"]*)" as rank for the "([^"]*)" tree$/ do |rank, tree_title|
  tree = Tree.find_by_title!(tree_title)
  id   = tree.type == 'MasterTree' ? 'add-node-wrap +' : "reference_tree_#{tree.id}"
  page.should have_css("##{id} .node-metadata .metadata-rank ul li a span:contains('#{rank.strip}')")
end

When /^I rename the synonym "([^"]*)" to "([^"]*)"$/ do |old_synonym, new_synonym|
  page.execute_script("jQuery('div.node-metadata li a span:contains(#{old_synonym.strip})').dblclick();")
  field = find(:css, "input.metadata-input")
  field.set(new_synonym.strip)
  page.execute_script("jQuery('input.metadata-input').blur();")
  sleep 2
end

When /^I edit the rank to "([^"]*)"$/ do |new_rank|
  page.execute_script("jQuery('div.node-metadata li.rank').dblclick();")
  field = find(:css, "input.metadata-input")
  field.set(new_rank)
  page.execute_script("jQuery('input.metadata-input').blur();")
end

Then /^the synonym should be of type "([^"]*)"$/ do |type|
  page.should have_xpath("//a[@class='nav-view-checked']", :text => type)
end
