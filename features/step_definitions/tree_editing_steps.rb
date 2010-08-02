Then /^I should see a node "([^"]*)" at the root level in my master tree$/ do |node_text|
  with_scope('.jstree-leaf') do
    page.should have_content(node_text)
  end
end

When /^I enter "([^"]*)" in the new node and press enter$/ do |text|
  field = find(:css, ".jstree-last input")
  field.set(text)

  page.execute_script("$('.jstree-last input').blur();")
end
