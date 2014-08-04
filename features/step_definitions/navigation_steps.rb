When /^I reload the page$/ do
  visit(current_url)
end

Then /^the "([^"]*)" bar should be highlighted$/ do |bar_text|
  step %{I should see "#{bar_text}" within "#active"}
end

Then /^the "([^"]*)" bar should not be highlighted$/ do |bar_text|
  step %{I should not see "#{bar_text}" within "#active"}
end

