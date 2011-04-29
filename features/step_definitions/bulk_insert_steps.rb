When /^I type the following node names into the bulk insert box:$/ do |node_names_table|
  field = find(:css, "#bulkcreate-form textarea")
  field.set("#{node_names_table.raw.join("\n")}")
end
