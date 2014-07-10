Given /^the following nodes exist with metadata for the "([^"]*)" tree:$/ do |tree_title, table|
  tree = Tree.find_by_title!(tree_title)

  table.hashes.each do |hash|
    node = Factory(:node, name: Factory(:name, name_string: hash['name']), tree: tree, rank: hash['rank'])

    hash['synonyms'].split(',').each do |synonym|
      Factory(:synonym, name: Factory(:name, name_string: synonym.strip), node: node)
    end

    hash['vernacular_names'].split(',').each do |vernacular_name|
      Factory(:vernacular_name, name: Factory(:name, name_string: vernacular_name.strip), node: node)
    end
  end
end
