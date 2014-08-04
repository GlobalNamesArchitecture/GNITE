When /^I type the following node names into the import box:$/ do |node_names_table|
  step %{I fill in "List of Taxa" with "#{node_names_table.raw.join("\n")}"}
end

When "I import a flat list tree with the following nodes:" do |node_names_table|
  step %{I follow "Import"}
  step %{I follow "Enter Flat List"}
  step %{I fill in "Title" with "List"}
  step %{I fill in "List of Taxa" with "#{node_names_table.raw.join("\n")}"}
  step %{I press "Import"}
end

