#!/usr/bin/env ruby
require "dwc-archive"
require 'json'

class Node
  attr_reader :classification

  def logger
    @logger || Logger.new($stdout)
  end

  def initialize(dwca_file)
    @dwca = DarwinCore.new(dwca_file)
    DarwinCore.logger = logger
    logger.info("Creating classification tree")
    @classification = DarwinCore::ClassificationNormalizer.new(@dwca)
    @classification.normalize
    @leaves = []
    @empty_nodes = []
  end

  def leaves(node_id)
    node = @classification.normalized_data[node_id]
    path = node.classification_path_id
    @node_path_size = path.size - 1
    current_node = @classification.tree
    until path.empty? do
      current_node = current_node[path.shift]
    end
    walk_tree(current_node)
    [@leaves, @empty_nodes]
  end

  private

  def walk_tree(current_node)
    current_node.keys.each do |key|
      get_data(key, current_node[key].empty?)
      walk_tree(current_node[key])
    end
  end

  def get_data(node_id, node_is_empty)
    node = @classification.normalized_data[node_id]
    if is_species?(node.current_name_canonical)
      add_node(@leaves, node)
    elsif node_is_empty
      add_node(@empty_nodes, node)
    end
  end

  def add_node(res, node)
    range = @node_path_size..node.classification_path.size
    valid_name = {:name => node.current_name, :canonical_name => node.current_name_canonical, :type => :valid, :status => node.status}
    synonyms = node.synonyms.inject([]) do |res, syn|
      res << {:name => syn.name, :canonical_name => syn.canonical_name, :type => :synonym, :status => syn.status}
    end
    res << {:id => node.classification_path_id.last, :path => node.classification_path[range], :path_ids => node.classification_path_id[range], :rank => node.rank, :valid_name => valid_name, :synonyms => synonyms}
  end

  def is_species?(name_string)
    name_string.split(/\s+/).size >= 2
  end

end

if __FILE__ == $0

  unless ARGV[1]
    puts "script creates a json file with data compatible for family-reunion from a darwin core archive"
    puts "Usage #{$0} path_to_dwca_file node_id [output_file]"
    puts "output_file is optional"
    exit
  end

  dwca_file = ARGV[0]
  node_id = ARGV[1]
  paths_file = ARGV[2] ? ARGV[2] : "node_leaves.json"

  node = Node.new(dwca_file)
  leaves, empty_nodes = node.leaves(node_id)
  f = open(paths_file,'w')
  f.write JSON.dump({:empty_nodes => empty_nodes, :leaves => leaves})
end
