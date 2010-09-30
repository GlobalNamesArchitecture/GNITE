When /^I search for "([^"]*)"$/ do |search_term|
  field = find("#search")
  field.set(search_term)
  page.execute_script("jQuery('#search').blur();")
end

Then /^I should see a total count of (\d+) in "([^\"]+)"/ do |count, section_named_element|
  section_selector = named_element_for(section_named_element)
  within(section_selector) do
    page.should have_css("p.count", :text => count)
  end
end

When /^the search results return$/ do
  loaded = false
  When %{pause 1}
  until loaded
    loaded = page.has_css?("#search-results")
  end
end

Then /^I should see that "(.*)" has (\d+) results?$/ do |named_element, count|
  tab_selector = element_for(named_element)
  within(tab_selector) do
    page.should have_css('div.count', :text => count)
  end
end

Then /^the search results should contain the following classifications:$/ do |classifications|
  classifications.hashes.each do |row|
    within("ul.classifications li##{row['uuid']}") do
      page.should have_css('div.title', :text => row['title'])
      page.should have_css('div.description', :text => row['description'])
      page.should have_css('div.rank', :text => row['rank'])
      page.should have_css('div.path', :text => row['path'].gsub("/", " › "))
      page.should have_css('div.current_name', :text => row['current name'].gsub("/", "|"))
      page.should have_css('div.found_as', :text => row['found as'])
    end
  end
end

Then /^the "([^\"]+)" result should have the following authors:$/ do |current_name, authors|
  within("div.current_name:contains('#{current_name}') ~ .authors") do
    authors.hashes.each do |row|
        page.should have_css('div.name', :text => "#{row['first name']} #{row['last name']} ( #{row['email']} )")
    end
  end
end

When /^I press "([^\"]+)" next to the "([^\"]+)" classification$/ do |button_label, classification_current_name|
  within('.classifications') do
    button = page.locate("div.current_name:contains('#{classification_current_name}') ~ button", :text => button_label)
    button.click
  end
end
