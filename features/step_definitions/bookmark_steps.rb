Given /^there is an existing bookmark called "([^"]*)" for a node "([^"]*)"$/ do |bookmark_title, name_string|
  Factory(:bookmark, :bookmark_title => bookmark_title, :node => ::Node.joins(:name).where('names.name_string = ?', name_string).first)
end

Then /^I should see a bookmark "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.should have_css("div.bookmarks-master>div>ul>li>a:contains('#{bookmark_text}')")
end

Then /^I should not see a bookmark "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.should_not have_css("div.bookmarks-master>div>ul>li>a:contains('#{bookmark_text}')")
end

Then /^I delete "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.execute_script("jQuery('div.bookmarks-master').find('a:contains(\"#{bookmark_text}\")').next('a.bookmarks-delete').click();")
  sleep 2
end

When /^I wait for the bookmark form to load$/ do
  loaded = false
  When %{pause 1}
  while !loaded
    loaded = page.has_css?(".bookmark-addition")
  end
end

When /^I wait for the bookmark results to load$/ do
  loaded = false
  When %{pause 1}
  while !loaded
    loaded = page.has_css?(".bookmarks-results")
  end
end