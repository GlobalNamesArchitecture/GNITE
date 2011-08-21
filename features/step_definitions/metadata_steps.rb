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
  if tree.type == 'MasterTree'
    page.should have_css("#add-node-wrap + .node-metadata .metadata-rank ul li a span:contains('#{rank.strip}')")
  else
    page.should have_css("#reference_tree_#{tree.id} .node-metadata .metadata-rank ul li:contains('#{rank.strip}')")
  end
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
  sleep 2
end

Then /^the synonym "([^"]*)" should be of type "([^"]*)"$/ do |synonym, type|
  synonym_type = find(:xpath, "//li[@class='synonym']/a/span[contains(.,'#{synonym}')]/parent::node()/parent::node()/ul[@class='subnav']/li/a[@class='nav-view-checked']")
  if synonym_type.text.respond_to? :should
    synonym_type.text.should == "#{type}"
  else
    assert_match("#{type}", synonym_type.text)
  end
end

When /^I add a new synonym "([^"]*)"$/ do |new_synonym|
  page.execute_script("jQuery('.metadata-synonyms li.metadata-add').click();")
  field = find(:css, "input.metadata-input")
  field.set(new_synonym)
  page.execute_script("jQuery('input.metadata-input').blur();")
  sleep 2
end

When /^I add a new vernacular "([^"]*)"$/ do |new_vernacular|
  page.execute_script("jQuery('.metadata-vernacular-names li.metadata-add').click();")
  field = find(:css, "input.metadata-input")
  field.set(new_vernacular)
  page.execute_script("jQuery('input.metadata-input').blur();")
  sleep 2
end

When /^I change the language to "([^"]*)"$/ do |language|
  field = find(:css, "li.vernacular ul.subnav li input.metadata-autocomplete")
  field.set(language)
  page.execute_script("jQuery('li.vernacular ul.subnav li input.metadata-autocomplete').blur();")
  sleep 2
end

Then /^I should see "([^"]*)" as the vernacular language for "([^"]*)"$/ do |language, vernacular|
  field = find(:xpath, "//li[@class='vernacular']/a/span[contains(.,'#{vernacular}')]/parent::node()/parent::node()/ul[@class='subnav']/li/input[@class='metadata-autocomplete']")
  if field.value.respond_to? :should
    field.value.should =~ /#{language}/
  else
    assert_match(/#{language}/, field.value)
  end
end