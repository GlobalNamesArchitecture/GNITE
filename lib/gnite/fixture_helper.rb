# encoding: utf-8
module Gnite::FixtureHelper
  def self.get_master_tree1(options = {})
    english = Language.find_by_iso_639_1('en')
    user = FactoryGirl.create(:user) unless options[:user]
    tree = FactoryGirl.create(:master_tree,
                   title: (options[:title].nil? ? "Master Tree One" : options[:title]), 
                   user_id: (options[:user].nil? ? user.id : options[:user].id),
                   user: (options[:user].nil? ? user : options[:user])
           )
    merge_node = FactoryGirl.create(:node, tree: tree, name: Name.find_or_create_by_name_string("Lycosidae"))
    bulk_add1 = FactoryGirl.create(:action_bulk_add_node, tree_id: tree.id, parent_id: merge_node.id, json_message: '{"do": ["Pardosa", "Schizocosa", "Trochosa", "Alopecosa"]}')
    ActionBulkAddNode.perform(bulk_add1.id)
    genera_ids = JSON.parse(bulk_add1.reload.json_message)['undo']
    bulk_add2 = FactoryGirl.create(:action_bulk_add_node, tree_id: tree.id, parent_id: genera_ids[0], json_message: '{"do": ["Pardosa moesta Banks, 1892", "Pardosa modica (Keyserling, 1887)", "Pardosa fuscula (Keyserling, 1887)", "Pardosa xerampelina Keyserling, 1887" , "Pardosa zelotes Keyserling, 1887", "Pardosa groenlandica Banks, 1892", "Pardosa opeongo Banks, 1800"]}')
    ActionBulkAddNode.perform(bulk_add2.id)
    pardosa_ids = JSON.parse(bulk_add2.reload.json_message)['undo']
    FactoryGirl.create(:synonym, node_id: pardosa_ids[0], name: Name.find_or_create_by_name_string("Lycosa moesta Banks, 1892"))
    FactoryGirl.create(:synonym, node_id: pardosa_ids[1], name: Name.find_or_create_by_name_string("Lycosa modica Keyserling, 1887"))
    FactoryGirl.create(:vernacular_name, node_id: pardosa_ids[0], name: Name.find_or_create_by_name_string("Thin-legged wolf spider"), language: english)
    tree
  end

  def self.get_master_tree2(options = {})
    portuguese = Language.find_by_iso_639_1('pt')
    user = FactoryGirl.create(:user) unless options[:user]
    tree = FactoryGirl.create(:master_tree,
                   title: (options[:title].nil? ? "Master Tree Two" : options[:title]),
                   user_id: (options[:user].nil? ? user.id : options[:user].id),
                   user: (options[:user].nil? ? user : options[:user])
           )
    merge_node = FactoryGirl.create(:node, tree: tree, name: Name.find_or_create_by_name_string("Lycosidae"))
    bulk_add1 = FactoryGirl.create(:action_bulk_add_node, tree_id: tree.id, parent_id: merge_node.id, json_message: '{"do": ["Pardosa", "Schizocosa", "Varacosa", "Trochosa", "Alopecosa", "Crocodilosa"]}')
    ActionBulkAddNode.perform(bulk_add1.id)
    genera_ids = JSON.parse(bulk_add1.reload.json_message)['undo']
    bulk_add2 = FactoryGirl.create(:action_bulk_add_node, tree_id: tree.id, parent_id: genera_ids[0], json_message: '{"do": ["Parosa moesta Banksy, 1892", "Pardosa modica (Keyserling, 1887)", "Pardosa fuscula Keyserling, 1886", "Pardosa xerampelina Keyserling, 1887", "Pardosa agricola (Thorell, 1856)", "Pardosa zalotes Keyserling, 1887"]}')
    bulk_add3 = FactoryGirl.create(:action_bulk_add_node, tree_id: tree.id, parent_id: genera_ids[1], json_message: '{"do": ["Schizocosa ocreata", "Schizocosa saltatrix"]}')
    bulk_add4 = FactoryGirl.create(:action_bulk_add_node, tree_id: tree.id, parent_id: genera_ids[2], json_message: '{"do": ["Varacosa avara", "Varacosa banksiana"]}')
    bulk_add5 = FactoryGirl.create(:action_bulk_add_node, tree_id: tree.id, parent_id: genera_ids[3], json_message: '{"do": ["Trochosa terricola (Thorell, 1857)", "Trochosa ruricola"]}')
    bulk_add6 = FactoryGirl.create(:action_bulk_add_node, tree_id: tree.id, parent_id: genera_ids[5], json_message: '{"do": ["Crocodilosa kittenbergeri Caporiacco, 1947", "Crocodilosa leucostigma (Simon, 1885)", "Crocodilosa maindroni (Simon, 1897)", "Crocodilosa ovicula (Thorell, 1895)", "Crocodilosa virulenta (O. P.-Cambridge, 1876)"]}')
    ActionBulkAddNode.perform(bulk_add2.id)
    ActionBulkAddNode.perform(bulk_add3.id)
    ActionBulkAddNode.perform(bulk_add4.id)
    ActionBulkAddNode.perform(bulk_add5.id)
    ActionBulkAddNode.perform(bulk_add6.id)
    pardosa_ids = JSON.parse(bulk_add2.reload.json_message)['undo']
    varacosa_ids = JSON.parse(bulk_add4.reload.json_message)['undo']
    FactoryGirl.create(:synonym, node_id: pardosa_ids[0], name: Name.find_or_create_by_name_string("Lycosa moesta Banks, 1892"))
    FactoryGirl.create(:synonym, node_id: varacosa_ids[0], name: Name.find_or_create_by_name_string("Pordosa groenlindica B. 1891"))
    FactoryGirl.create(:synonym, node_id: varacosa_ids[1], name: Name.find_or_create_by_name_string("Pardosa opeongo Smith, 1800"))
    FactoryGirl.create(:synonym, node_id: pardosa_ids[1], name: Name.find_or_create_by_name_string("Lycosa modiica Keyserling, 1887"))
    FactoryGirl.create(:synonym, node_id: pardosa_ids[2], name: Name.find_or_create_by_name_string("Lycosa fuscula Keyserling, 1887"))
    FactoryGirl.create(:vernacular_name, node_id: pardosa_ids[0], name: Name.find_or_create_by_name_string("Tarântula Gordura"), language: portuguese)
    FactoryGirl.create(:vernacular_name, node_id: pardosa_ids[4], name: Name.find_or_create_by_name_string("Lobo Aranha Peluda"), language: portuguese)
    tree
  end
end
