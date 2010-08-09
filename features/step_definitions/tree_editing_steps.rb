Then /^I should see a node "([^"]*)" at the root level in my master tree$/ do |node_text|
  with_scope('.jstree-leaf') do
    page.should have_content(node_text)
  end
end

Then /^I should not see a node "([^"]*)" at the root level in my master tree$/ do |node_text|
  with_scope('.jstree-leaf') do
    page.should_not have_content(node_text)
  end
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
  parent_node_id = Node.find_by_name(parent_node_text).id
  child_node_id = Node.find_by_name(child_node_text).id

  with_scope("##{parent_node_id}") do
    page.should have_css("##{child_node_id}")
  end
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
  node = Node.find_by_name(node_name)
  page.execute_script("jQuery('#master-tree').jstree('open_node', '##{node.id}');")
end

Then /^pause (\d)$/ do |num|
  time = Time.now
  while Time.now - time < num.to_i
  end
end

When /^I drag "([^"]*)" under "([^"]*)"$/ do |child_node_text, parent_node_text|
  child_node = Node.find_by_name(child_node_text)
  parent_node = Node.find_by_name(parent_node_text)
  #This calls the "move_node" function from the core api directly
  #but the same function is also called during mouse drag and drops
  When %{I select the node "#{child_node.name}"}
  #When %{I follow "#{child_node.id}"}
  page.execute_script("jQuery('#master-tree').jstree('move_node', '##{child_node.id}', '##{parent_node.id}', 'first', false);")

end

When /^I delete the node "([^"]*)"$/ do |node_text|
  node = Node.find_by_name(node_text)
  page.execute_script("jQuery('#master-tree').jstree('remove', '##{node.id}');")
end

Then /^the "([^"]*)" tree node should be selected$/ do |node_text|
  node = Node.find_by_name(node_text)
  puts page.body
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
