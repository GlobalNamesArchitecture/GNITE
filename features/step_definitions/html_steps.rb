Then /^"([^"]*)" should link to email "([^"]*)"$/ do |locator, email|
  link = find_link(locator)
  link['href'].should == "mailto:#{email}"
end

Then /^I should be focused on (.*)$/ do |selector|
  element = element_for(selector)
  page.evaluate_script("jQuery('#{element}')[0] === document.activeElement").should be_truthy
end

When /^I click on the page$/ do
  page.execute_script <<-JS
    jQuery(document.activeElement).blur();
  JS
end

Then /^"([^"]*)" should be checked/ do |label|
  field = find_field(label)
  field['checked'].should == 'true'
end
