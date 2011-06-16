# encoding: utf-8
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'factory_girl'
Factory.find_definitions
require 'shoulda'

RSpec.configure do |config|
  config.mock_with :mocha
  config.use_transactional_fixtures = true
  config.include SessionHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    csv_dir = File.join(Rails.root.to_s, 'db', 'csv')
    Dir.entries(csv_dir).each do |file|
      next if file[-4..-1] != '.csv'
      table_name = file.gsub(/.csv$/, '')
      ::Node.connection.execute "load data infile '#{File.join(csv_dir, file)}' into table #{table_name} character set utf8"  
    end
  end

  config.after(:suite) do
    Gnite::ResqueHelper.cleanup
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end


def get_tree1
  english = Language.find_by_iso_639_1('en')
  tree = Factory(:master_tree)
  merge_node = Factory(:node, :tree => tree, :name => Name.find_or_create_by_name_string("Lycosidae"))
  bulk_add1 = Factory(:action_bulk_add_node, :tree_id => tree.id, :parent_id => merge_node.id, :json_message => '{"do": ["Pardosa", "Schizocosa", "Trochosa", "Alopecosa"]}')
  ActionBulkAddNode.perform(bulk_add1.id)
  genera_ids = JSON.parse(bulk_add1.reload.json_message)['undo']
  bulk_add2 = Factory(:action_bulk_add_node, :tree_id => tree.id, :parent_id => genera_ids[0], :json_message => '{"do": ["Pardosa moesta Banks, 1892", "Pardosa modica (Keyserling, 1887)", "Pardosa fuscula (Keyserling, 1887)", "Pardosa xerampelina Keyserling, 1887" , "Pardosa zelotes Keyserling, 1887", "Pardosa groenlandica Banks, 1892", "Pardosa opeongo Banks, 1800"]}')
  ActionBulkAddNode.perform(bulk_add2.id)
  pardosa_ids = JSON.parse(bulk_add2.reload.json_message)['undo']
  Factory(:synonym, :node_id => pardosa_ids[0], :name => Name.find_or_create_by_name_string("Lycosa moesta Banks, 1892"))
  Factory(:synonym, :node_id => pardosa_ids[1], :name => Name.find_or_create_by_name_string("Lycosa modica Keyserling, 1887"))
  Factory(:vernacular_name, :node_id => pardosa_ids[0], :name => Name.find_or_create_by_name_string("Thin-legged wolf spider"), :language => english)
  tree
end

def get_tree2
  portuguese = Language.find_by_iso_639_1('pt')
  tree = Factory(:master_tree)
  merge_node = Factory(:node, :tree => tree, :name => Name.find_or_create_by_name_string("Lycosidae"))
  bulk_add1 = Factory(:action_bulk_add_node, :tree_id => tree.id, :parent_id => merge_node.id, :json_message => '{"do": ["Pardosa", "Schizocosa", "Varacosa", "Trochosa", "Alopecosa"]}')
  ActionBulkAddNode.perform(bulk_add1.id)
  genera_ids = JSON.parse(bulk_add1.reload.json_message)['undo']
  bulk_add2 = Factory(:action_bulk_add_node, :tree_id => tree.id, :parent_id => genera_ids[0], :json_message => '{"do": ["Parosa moesta Banksy, 1892", "Pardosa modica (Keyserling, 1887)", "Pardosa fuscula Keyserling, 1886", "Pardosa xerampelina Keyserling, 1887", "Pardosa agricola (Thorell, 1856)", "Pardosa zalotes Keyserling, 1887"]}')
  bulk_add3 = Factory(:action_bulk_add_node, :tree_id => tree.id, :parent_id => genera_ids[1], :json_message => '{"do": ["Schizocosa ocreata", "Schizocosa saltatrix"]}')
  bulk_add4 = Factory(:action_bulk_add_node, :tree_id => tree.id, :parent_id => genera_ids[2], :json_message => '{"do": ["Varacosa avara", "Varacosa banksiana"]}')
  bulk_add5 = Factory(:action_bulk_add_node, :tree_id => tree.id, :parent_id => genera_ids[3], :json_message => '{"do": ["Trochosa terricola (Thorell, 1857)", "Trochosa ruricola"]}')
  ActionBulkAddNode.perform(bulk_add2.id)
  ActionBulkAddNode.perform(bulk_add3.id)
  ActionBulkAddNode.perform(bulk_add4.id)
  ActionBulkAddNode.perform(bulk_add5.id)
  pardosa_ids = JSON.parse(bulk_add2.reload.json_message)['undo']
  varacosa_ids = JSON.parse(bulk_add4.reload.json_message)['undo']
  Factory(:synonym, :node_id => pardosa_ids[0], :name => Name.find_or_create_by_name_string("Lycosa moesta Banks, 1892"))
  Factory(:synonym, :node_id => varacosa_ids[0], :name => Name.find_or_create_by_name_string("Pordosa groenlindica B. 1891"))
  Factory(:synonym, :node_id => varacosa_ids[1], :name => Name.find_or_create_by_name_string("Pardosa opeongo Smith, 1800"))
  Factory(:synonym, :node_id => pardosa_ids[1], :name => Name.find_or_create_by_name_string("Lycosa modiica Keyserling, 1887"))
  Factory(:synonym, :node_id => pardosa_ids[2], :name => Name.find_or_create_by_name_string("Lycosa fuscula Keyserling, 1887"))
  Factory(:vernacular_name, :node_id => pardosa_ids[0], :name => Name.find_or_create_by_name_string("Tarântula Gordura"), :language => portuguese)
  Factory(:vernacular_name, :node_id => pardosa_ids[4], :name => Name.find_or_create_by_name_string("Lobo Aranha Peluda"), :language => portuguese)
  tree
end
