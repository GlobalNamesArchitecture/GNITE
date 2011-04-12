Given /^there is an existing bookmark for a node "([^"]*)"$/ do |name_string|
  Factory(:bookmark, :node => ::Node.joins(:name).where('names.name_string = ?', name_string).first)
end

Then /^I should see a bookmark "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.should have_css("div#toolbar .bookmarks-results>div>ul>li>a:contains('#{bookmark_text}')")
end

Then /^I should not see a bookmark "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.should_not have_css("div#toolbar .bookmarks-results>div>ul>li>a:contains('#{bookmark_text}')")
end

Then /^I delete "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.execute_script("jQuery('div#toolbar .bookmarks-results').find('a:contains(\"#{bookmark_text}\")').next('a.bookmarks-delete').click();")
  sleep 2
end