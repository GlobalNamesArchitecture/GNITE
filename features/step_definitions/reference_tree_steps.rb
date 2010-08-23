Then /^I should see a node "([^"]*)" at the root level in my reference tree$/ do |node_text|
  page.should have_css("div#reference-tree>ul>li>a:contains('#{node_text}')")
end

Then /^I should see a "([^"]*)" tab$/ do |tab_name|
  page.should have_css("li.tab>a:contains('#{tab_name}')")
end
