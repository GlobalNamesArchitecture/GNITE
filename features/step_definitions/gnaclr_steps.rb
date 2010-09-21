Given /^GNACLR contains the following classifications:$/ do |table|
  table.hashes.each do |hash|
    FakeGnaclr::Store.insert(hash)
  end
end

Given /^the GNACLR classification "([^"]*)" has the following revisions:$/ do |classification_title, table|
  table.hashes.each do |revision_attributes|
    FakeGnaclr::Store.insert_revision_for_classification_title(:revision_attributes => revision_attributes, :classification_title => classification_title)
  end
end
