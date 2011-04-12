# encoding: utf-8
When /^I search for "([^"]*)" in GNACLR$/ do |search_term|
  field = find("#gnaclr-search")
  field.set(search_term)
  page.execute_script("jQuery('#gnaclr-search').blur();")
end

Then /^I should see a total count of (\d+) in "([^\"]+)"/ do |count, section_named_element|
  section_selector = named_element_for(section_named_element)
  within(section_selector) do
    page.should have_css("p.count", :text => count)
  end
end

When /^the GNACLR search results return$/ do
  loaded = false
  When %{pause 1}
  until loaded
    loaded = page.has_css?("#gnaclr-search-results") || page.has_css?("#gnaclr-error")
  end
end

Then /^I should see that "(.*)" has (\d+) results?$/ do |named_element, count|
  tab_selector = element_for(named_element)
  within(tab_selector) do
    page.should have_css('div.count', :text => count)
  end
end

Then /^the GNACLR search results should contain the following classifications:$/ do |classifications|
  classifications.hashes.each do |row|
    within("ul.classifications li##{row['uuid']}") do
      page.should have_css('div.title', :text => row['title'])
      page.should have_css('div.description', :text => row['description'])
      page.should have_css('td.rank', :text => row['rank'])
      page.should have_css('td.path', :text => row['path'].gsub("/", " › "))
      page.should have_css('td.current-name', :text => row['current name'].gsub("/", "|"))
      page.should have_css('td.found-as', :text => row['found as'])
    end
  end
end

Then /^the "([^\"]+)" result should have the following authors:$/ do |title, authors|
  within("div.title:contains('#{title}') ~ table .authors") do
    authors.hashes.each do |row|
      page.should have_css('div.name', :text => /#{row['first name']} #{row['last name']}/)
    end
  end
end

When /^I press "([^\"]+)" next to the "([^\"]+)" classification$/ do |button_label, title|
  within('.classifications') do
    button = page.locate("div.title:contains('#{title}') ~ .import-button button", :text => button_label)
    button.click
  end
end

Given /^the GNACLR search service is unavailable$/ do
  ShamRack.unmount_all
  ShamRack.at(GnaclrSearch::URL) do
    [ 500,  {}, [' '] ]
  end
end
