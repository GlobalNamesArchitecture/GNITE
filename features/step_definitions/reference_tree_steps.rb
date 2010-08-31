Then /^I should see a node "([^"]*)" at the root level in my reference tree "([^"]*)"$/ do |node_text, reference_tree_title|
  reference_tree = ReferenceTree.find_by_title(reference_tree_title)
  page.should have_css("div##{dom_id(reference_tree, "container_for")}>ul>li>a:contains('#{node_text}')")
end

Then /^I should see a "([^"]*)" tab$/ do |tab_name|
  page.should have_css("ul.ui-tabs-nav>li>a:contains('#{tab_name}')")
end

Then /^the "([^"]*)" tab should be active$/ do |tab_name|
  page.should have_css("ul.ui-tabs-nav>li.ui-state-active>a:contains('#{tab_name}')")
end

