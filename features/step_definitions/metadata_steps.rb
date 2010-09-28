Then /^I should see "([^"]*)" as synonyms$/ do |synonyms|
  synonyms.split(',').each do |synonym|
    page.should have_css(".node-metadata .metadata-synonyms ul li:contains('#{synonym.strip}')")
  end
end

Then /^I should see "([^"]*)" as vernacular names$/ do |vernacular_names|
  vernacular_names.split(',').each do |vernacular_name|
    page.should have_css(".node-metadata .metadata-vernacular-names ul li:contains('#{vernacular_name.strip}')")
  end
end

Then /^I should see "([^"]*)" as rank$/ do |rank|
  page.should have_css(".node-metadata .metadata-rank ul li:contains('#{rank.strip}')")
end
