# encoding: utf-8
When /^I search for "([^"]*)" in the master tree search box$/ do |search_term|
  field = find("#treewrap-main .tree-search")
  field.set(search_term)
  page.execute_script("jQuery('#treewrap-main .tree-search').blur();")
  sleep 2
end

Then /^I should see "([^\"]*)" in the master tree search results$/ do |search_result|
  page.should have_css("#treewrap-main .searchbar-results>div>ul>li>a:contains('#{search_result}')")
end

Then /^I should see "([^\"]*)" in the master tree search results when nothing is found$/ do |message|
  page.should have_css("#treewrap-main .searchbar-results>div:contains('#{message}')")
end