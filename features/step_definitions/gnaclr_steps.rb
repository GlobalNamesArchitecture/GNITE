Given /^GNACLR contains the following classifications:$/ do |table|
  table.hashes.each do |hash|
    FakeGnaclr::Store.insert(hash)
  end
end

Given /^the GNACLR classification "([^"]*)" has the following revisions:$/ do |classification_title, table|
  pending
  # table.hashes.each do |hash|
  #   FakeGnaclr::Store.insert_revision_with_message_for_classification_title(hash['message'], classification_title)
  # end
end
