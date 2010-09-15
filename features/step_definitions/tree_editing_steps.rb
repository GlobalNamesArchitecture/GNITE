Then /^I should see a node "([^"]*)" at the root level in my master tree$/ do |node_text|
  page.should have_css("div#master-tree>ul>li>a:contains('#{node_text}')")
end

Then /^I should see (\d+) child nodes? for the "([^"]*)" node in my master tree$/ do |node_count, parent_node_text|
  all("div#master-tree > ul > li > a:contains('#{parent_node_text}') + ul > li").count.should == node_count.to_i
end

Then /^I should not see a node "([^"]*)" at the root level in my master tree$/ do |node_text|
  page.should_not have_css("div#master-tree>ul>li>a:contains('#{node_text}')")
  # page.should_not have_xpath("//div[@id='master-tree']/ul/li/a[contains(., '#{node_text}')]")
end

When /^I enter "([^"]*)" in the new node and press enter$/ do |text|
  field = find(:css, ".jstree-last input")
  field.set(text)

  page.execute_script("jQuery('.jstree-last input').blur();")
end

When /^I select the node "([^"]*)"$/ do |node_text|
  When %{I follow "#{node_text}"}
end

Then /^I should see a node "([^"]*)" under "([^"]*)"$/ do |child_node_text, parent_node_text|
  page.should have_css("#master-tree ul>li>a:contains('#{parent_node_text}')+ul>li>a:contains('#{child_node_text}')")
end

When /^I double click "([^"]*)" and change it to "([^"]*)"$/ do |old_name, new_name|
  When %{I follow "#{old_name}"}

  page.execute_script("jQuery('.jstree-clicked').dblclick();")
  field = find(:css, "#master-tree input")
  field.set(new_name)
  page.execute_script("jQuery(':input').blur();")
end

When /^I wait for the tree to load$/ do
  loaded = false
  When %{pause 1}
  while !loaded
    loaded = page.has_css?("#master-tree.loaded")
  end
end

When /^I expand the node "([^"]*)"$/ do |node_name|
  node = first_node_by_name(node_name)
  page.execute_script("jQuery('#master-tree').jstree('open_node', '##{node.id}');")
  sleep 1
end

When /^I expand the node "([^"]*)" under "([^"]*)"$/ do |child_node_name, parent_node_name|
  child_node = Node.all.detect { |node| node.parent && node.name_string == child_node_name && node.parent.name_string == parent_node_name }
  child_node.should_not be_nil
  page.execute_script("jQuery('#master-tree').jstree('open_node', '##{child_node.id}');")
  sleep 1
end


Then /^pause (\d+)$/ do |num|
  sleep(num.to_i)
end

When /^I drag "([^"]*)" under "([^"]*)"$/ do |child_node_text, parent_node_text|
  child_node = first_node_by_name(child_node_text)
  parent_node = first_node_by_name(parent_node_text)
  #This calls the "move_node" function from the core api directly
  #but the same function is also called during mouse drag and drops
  When %{I select the node "#{child_node.name_string}"}
  page.execute_script("jQuery('#master-tree').jstree('move_node', '##{child_node.id}', '##{parent_node.id}', 'first', false);")
end

When /^I delete the node "([^"]*)"$/ do |node_text|
  node = first_node_by_name(node_text)
  page.execute_script("jQuery('#master-tree').jstree('remove', '##{node.id}');")
end

Then /^the "([^"]*)" tree node should be selected$/ do |node_text|
  node = first_node_by_name(node_text)
  page.should have_css("li##{node.id} a.jstree-clicked")
end

When /^I click the master tree background$/ do
  page.execute_script("jQuery('#master-tree').closest('.tree-background').click();")
end

Then /^no nodes should be selected in the master tree$/ do
  page.should_not have_css("#master-tree a.jstree-clicked")
end

When /^I click a non\-text area of a node in the master tree$/ do
  page.should have_css('#master-tree li')
  page.execute_script("jQuery('#master-tree').find('li').first().click();")
end

When /^I click "([^"]*)" in the context menu$/ do |menu_selection|
  page.execute_script("jQuery('#master-tree').jstree('show_contextmenu');");
  sleep 1
  click_link(menu_selection)
end

Given /^the "([^"]*)" tree has a child node "([^"]*)" under "([^"]*)"$/ do |tree_title, child_node_name, parent_node_name|
  tree = Tree.find_by_title(tree_title)
  parent = first_node_by_name_for_tree(parent_node_name, tree)
  Factory(:node, :parent => parent, :name => child_node_name)
end

Then /^I should see "([^"]*)" under "([^"]*)" under "([^"]*)" in my master tree$/ do |grandchild, child, parent|
  page.should have_css("#master-tree ul>li>a:contains('#{parent}')+" +
                                    "ul>li>a:contains('#{child}')+" +
                                    "ul>li>a:contains('#{grandchild}')")
end
