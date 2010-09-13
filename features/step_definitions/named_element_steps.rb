When %r{^I follow ([^\"]+)$} do |named_element|
  selector = element_for(named_element)
  locate(selector).click
end

Then %r{^I should see "([^"]*)" within ([^"].*)$} do |expected_text, named_element|
  selector = element_for(named_element)
  within selector do
    page.should have_content(expected_text)
  end
end

Then %r{^I should not see "([^"]*)" within ([^"].*)$} do |expected_text, named_element|
  selector = element_for(named_element)
  within selector do
    page.should have_no_content(expected_text)
  end
end

Then /^(.*) should be hidden$/ do |named_element|
  selector = element_for(named_element)
  locate(selector).should_not be_visible
end

Then /^(.*) should be visible/ do |named_element|
  selector = element_for(named_element)
  locate(selector).should be_visible
end

When %r{^I follow "([^"]*)" within ([^"].*)$} do |link_text, named_element|
  selector = element_for(named_element)
  within selector do
    click_link link_text
  end
end

Then /^the page should (not )?contain ([^\"].*)$/ do |should_not_contain, named_element|
  selector = element_for(named_element)

  if should_not_contain.present?
    page.should have_no_css(selector)
  else
    page.should have_css(selector)
  end
end

Then /^([\w\s]+) should have a value of "([^\"]+)"$/ do |named_element, value|
  selector = element_for(named_element)
  locate(selector).value.should == value
end


Then /^([^\"].*) should be empty$/ do |named_element|
  selector = element_for(named_element)
  locate(selector).text.strip.should == ""
end

Then /^I should not see ([\w\s]+) within ([\w\s]+)$/ do |named_element, scope_named_element|
  scope = element_for(scope_named_element)
  selector = element_for(named_element)
  within(scope) do
    page.should have_no_css(selector)
  end
end

Then /^I should see ([\w\s]+) within ([\w\s]+)$/ do |named_element, scope_named_element|
  scope = element_for(scope_named_element)
  selector = element_for(named_element)
  within(scope) do
    page.should have_css(selector)
  end
end

Then /^I should see ([^"]*)$/ do |named_element|
  selector = element_for(named_element)
  page.should have_css(selector)
end

Then /^I should not see ([^"]*)$/ do |named_element|
  selector = element_for(named_element)
  page.should have_no_css(selector)
end

