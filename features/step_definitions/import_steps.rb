When /^I type the following node names into the import box:$/ do |node_names_table|
  When %{I fill in "List of Taxa" with "#{node_names_table.raw.join("\n")}"}
end

When "I import a flat list tree with the following nodes:" do |node_names_table|
  When %{I follow "Import"}
  And  %{I follow "Enter Flat List"}
  And  %{I fill in "Title" with "List"}
  And  %{I fill in "List of Taxa" with "#{node_names_table.raw.join("\n")}"}
  And  %{I press "Import"}
end

