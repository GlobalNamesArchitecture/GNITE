Given /^the following nodes exist with metadata for the "([^"]*)" tree:$/ do |tree_title, table|
  tree = Tree.find_by_title!(tree_title)

  table.hashes.each do |hash|
    node = FactoryGirl.create(:node, name: FactoryGirl.create(:name, name_string: hash['name']), tree: tree, rank: hash['rank'])

    hash['synonyms'].split(',').each do |synonym|
      FactoryGirl.create(:synonym, name: FactoryGirl.create(:name, name_string: synonym.strip), node: node)
    end

    hash['vernacular_names'].split(',').each do |vernacular_name|
      FactoryGirl.create(:vernacular_name, name: FactoryGirl.create(:name, name_string: vernacular_name.strip), node: node)
    end
  end
end
