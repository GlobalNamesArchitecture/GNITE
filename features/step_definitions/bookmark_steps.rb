Given /^there is an existing bookmark called "([^"]*)" for a node "([^"]*)"$/ do |bookmark_title, name_string|
  FactoryGirl.create(:bookmark, bookmark_title: bookmark_title, node: ::Node.joins(:name).where('names.name_string = ?', name_string).first)
end

Then /^I should see a bookmark "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.should have_xpath("//div[contains(@class, 'bookmarks-master')]/div/ul/li/span/a[contains(text(), '#{bookmark_text}')]")
end

Then /^I should not see a bookmark "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.should_not have_xpath("//div[contains(@class, 'bookmarks-master')]/div/ul/li/span/a[contains(text(), '#{bookmark_text}')]")
end

Then /^I delete "([^"]*)" in master tree bookmarks$/ do |bookmark_text|
  page.execute_script("jQuery('div.bookmarks-master').find('a:contains(\"#{bookmark_text}\")').parent().parent().find('a.bookmarks-delete').click();")
  sleep 2
end

Then /^I edit "([^"]*)" to be "([^"]*)" in master tree bookmarks$/ do |old_bookmark, new_bookmark|
  page.execute_script("jQuery('div.bookmarks-master').find('a:contains(\"#{old_bookmark}\")').parent().parent().find('a.bookmarks-edit').click();")
  sleep 1
  field = find(:css, "div.bookmarks-input input")
  field.set(new_bookmark)
  page.execute_script("jQuery('div.bookmarks-input').find('a.bookmarks-save').click();")
  sleep 1
end

When /^I wait for the bookmark form to load$/ do
  loaded = false
  step %{pause 1}
  while !loaded
    loaded = page.has_css?(".bookmark-addition")
  end
end

When /^I wait for the bookmark results to load$/ do
  loaded = false
  step %{pause 1}
  while !loaded
    loaded = page.has_css?(".bookmarks-results")
  end
end