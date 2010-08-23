Then /^"([^"]*)" should link to email "([^"]*)"$/ do |locator, email|
  link = find_link(locator)
  link['href'].should == "mailto:#{email}"
end
