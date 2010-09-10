When /^I type the following node names into the import box:$/ do |node_names_table|
  When %{I fill in "Import List of Nodes" with "#{node_names_table.raw.join("\n")}"}
end

When "I import a flat list tree with the following nodes:" do |node_names_table|
  When %{I follow "New Tab"}
  And  %{I follow "Import A Flat List"}
  And  %{I fill in "Import List of Nodes" with "#{node_names_table.raw.join("\n")}"}
  And  %{I press "Import"}
end

