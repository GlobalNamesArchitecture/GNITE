module Gnite
  module NodeMerge

    def deep_merge(merge_event)
      copy = self.clone
      copy.tree = merge_event.merge_tree
      copy.save!
      add_merges(merge_event, copy) if merge_has_node?(merge_event.id, self.id)
      copy.reload

      children.each do |child|
        child_copy = child.deep_merge(merge_event)
        child_copy.parent = copy
        child_copy.save!
      end
      copy
    end
  
    def merge_data(path = [self], result = { empty_nodes: [], leaves: []})
      self.children.each do |child|
        path_new = path.dup
        path_names = path.map(&:canonical_name) << child.canonical_name
        path_ids = path.map { |n| n.id.to_s } << child.id.to_s
        if child.canonical_name.split(' ').size > 1
          leaf = {id: child.id.to_s, rank: child.rank, path: path_names, path_ids: path_ids, valid_name: {name: child.name_string, canonical_name: child.canonical_name, type: 'valid', status: nil}, synonyms: []}
          child.synonyms.each do |synonym|
            leaf[:synonyms] << {name: synonym.name_string, canonical_name: synonym.canonical_name, status: synonym.status, type: 'synonym'}
          end
          result[:leaves] << leaf
        elsif !child.has_children?
          empty_node = {id: child.id.to_s, rank: child.rank, path: path_names, path_ids: path_ids, valid_name: {name: child.name_string, canonical_name: child.canonical_name, type: 'valid', status: nil}, synonyms: []}
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

    def add_merges(merge_event, node)
      @current_merged_node.merge_result_secondaries.each do |secondary_node|   
        if [MergeDecision.accepted.id, MergeDecision.postponed.id].include? secondary_node.merge_decision_id
          merge_node = Node.find(secondary_node.node_id)
          merge_type = secondary_node.merge_subtype ? "#{secondary_node.merge_type.label} #{secondary_node.merge_subtype.label}" : secondary_node.merge_type.label
          if merge_type == 'new'
            merge_node_copy = merge_node.clone
            merge_node_copy.tree = merge_event.merge_tree
            set_parent(merge_node_copy, node)
            copy_metadata(merge_node_copy, merge_node, merge_type)
            merge_node_copy.save!
          else
            copy_metadata(node, merge_node, merge_type)
          end
        end
      end
    end

    def copy_metadata(target_node, source_node, merge_type)
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
      
      if target_node.name != source_node.name
        if merge_type == 'exact valid to valid'
          Synonym.create(node_id: target_node.id, name: source_node.name, status: 'lexical variant') 
        else
          Synonym.create(node_id: target_node.id, name: source_node.name, status: 'merge alt name') 
        end
      end

    end

    #TODO slow method, speed it up if needed
    def set_parent(node, ancestor)
      canonical_parts = node.canonical_name.split(" ")
      if canonical_parts.size > 1
        if ancestor.canonical_name == canonical_parts[0]
          node.parent = ancestor
        elsif node_parent = get_parent_from_children(canonical_parts[0], ancestor)
          node.parent = node_parent
        else
          name = Name.find_or_create_by_name_string(canonical_parts[0])
          genus_node = Node.create!(tree: node.tree, name: name, parent_id: ancestor.id, rank: "genus")
          node.parent = genus_node
        end
      else
        node.parent = ancestor
      end
    end

    def get_parent_from_children(genus_name, ancestor)
      ancestor.children.each do |n| 
        return n if n.canonical_name == genus_name
      end
      nil 
    end

  end
end
