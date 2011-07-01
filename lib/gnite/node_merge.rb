module Gnite
  module NodeMerge

    def deep_merge(merge_event)
      copy = self.clone
      copy.tree = merge_event.merge_tree
      copy.save!

      children.each do |child|
        child_copy = child.deep_merge(merge_event)
        child_copy.parent = copy
        add_merges(merge_event, child, child_copy) if merge_has_node?(merge_event.id, child.id)
        child_copy.save! 
      end
      copy_metadata(copy, self)
      copy.reload
    end
  
    def merge_data(path = [self], result = { :empty_nodes => [], :leaves => []})
      self.children.each do |child|
        path_new = path.dup
        path_names = path.map(&:canonical_name) << child.canonical_name
        path_ids = path.map { |n| n.id.to_s } << child.id.to_s
        if child.canonical_name.split(' ').size > 1
          leaf = {:id => child.id.to_s, :rank => child.rank, :path => path_names, :path_ids => path_ids, :valid_name => {:name => child.name_string, :canonical_name => child.canonical_name, :type => 'valid', :status => nil}, :synonyms => []}
          child.synonyms.each do |synonym|
            leaf[:synonyms] << {:name => synonym.name_string, :canonical_name => synonym.canonical_name, :status => synonym.status, :type => 'synonym'}
          end
          result[:leaves] << leaf
        elsif !child.has_children?
          empty_node = {:id => child.id.to_s, :rank => child.rank, :path => path_names, :path_ids => path_ids, :valid_name => {:name => child.name_string, :canonical_name => child.canonical_name, :type => 'valid', :status => nil}, :synonyms => []}
          result[:empty_nodes] << empty_node
        end
        child.merge_data((path_new << child), result)
      end
      result
    end


    private

    def merge_has_node?(merge_event_id, node_id)
      @current_merged_node = MergeResultPrimary.where("merge_event_id = #{merge_event_id} and node_id = #{node_id}").limit(1)[0]
      !!@current_merged_node
    end

    def add_merges(merge_event, node, node_copy)
      @current_merged_node.merge_result_secondaries.each do |secondary_node|   
        if [MergeDecision.accepted.id, MergeDecision.postponed.id].include? secondary_node.merge_decision_id
          merge_node = Node.find(secondary_node.node_id)
          if secondary_node.merge_type.label == 'new'
            merge_node_copy = merge_node.clone
            merge_node_copy.parent = node_copy
            merge_node_copy.tree = merge_event.merge_tree
            merge_node_copy.save!
            copy_metadata(merge_node_copy, merge_node)
          else
            copy_metadata(node_copy, merge_node)
          end
        end
      end
    end

    def copy_metadata(target_node, source_node)
      known_vernaculars = target_node.vernacular_names.map { |v| v.name.name_string }.uniq
      known_synonyms = target_node.synonyms.map { |s| s.name.name_string }.uniq

      source_node.vernacular_names.each do |vernacular_name|
        unless known_vernaculars.include?(vernacular_name.name.name_string)
          vernacular_name_copy = vernacular_name.clone
          vernacular_name_copy.node = target_node
          vernacular_name_copy.save!
        end
      end

      source_node.synonyms.each do |synonym|
        unless known_synonyms.include?(synonym.name.name_string)
          synonym_copy = synonym.clone
          synonym_copy.node = target_node
          synonym_copy.save!
        end
      end
    end
  end
end
