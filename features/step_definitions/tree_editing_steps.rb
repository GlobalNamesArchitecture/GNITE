Then /^I should see a node "([^"]*)" at the root level in my master tree$/ do |node_text|
  with_scope('.jstree-leaf') do
    page.should have_content(node_text)
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

Then /^I should see a node "([^"]*)" under "([^"]*)"$/ do |parent_node_text, child_node_text|
  puts parent_node_text
  puts child_node_text
  puts "*"*80
  puts Node.all.map &:text
  parent_node_id = Node.find_by_name(parent_node_text).id
  child_node_id = Node.find_by_name(child_node_text).id

  with_scope("##{parent_node_id}") do
    page.should have_css("##{child_node_id}")
  end
  # page.should have_xpath "//li[contains(a, '#{parent_node_text}')]/ul/li[contains(a, '#{child_node_text}')]"
end

When /^I double click "([^"]*)" and change it to "([^"]*)"$/ do |old_name, new_name|
  When %{I follow "#{old_name}"}

  page.execute_script("jQuery('.jstree-clicked').dblclick();
                       jQuery(':input').attr('id', 'temp-input');")
  field = find(:css, "#master-tree input")
  field.set(new_name)
  page.execute_script("jQuery(':input').blur();")
end

When /^I wait for the tree to load$/ do
  loaded = false
  while !loaded
    loaded = page.has_css?("#master-tree.loaded")
  end
end
