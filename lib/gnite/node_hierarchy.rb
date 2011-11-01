module Gnite
  module NodeHierarchy
    def deep_copy_to(tree)
      copy = self.clone
      copy.tree = tree
      copy.save!

      children.each do |child|
        child_copy = child.deep_copy_to(tree)
        child_copy.parent = copy
        child_copy.save!
      end

      synonyms.each do |synonym|
        synonym_copy = synonym.clone
        synonym_copy.node = copy
        synonym_copy.save!
        
        synonym.lexical_variants.each do |lexical_variant|
          lexical_variant_copy = lexical_variant.clone
          lexical_variant_copy.lexicalable = synonym_copy
          lexical_variant_copy.save!
        end
      end

      vernacular_names.each do |vernacular_name|
        vernacular_name_copy = vernacular_name.clone
        vernacular_name_copy.node = copy
        vernacular_name_copy.save!
        
        vernacular_name.lexical_variants.each do |lexical_variant|
          lexical_variant_copy = lexical_variant.clone
          lexical_variant_copy.lexicalable = vernacular_name_copy
          lexical_variant_copy.save!
        end
      end

      lexical_variants.each do |lexical_variant|
        lexical_variant_copy = lexical_variant.clone
        lexical_variant_copy.lexicalable = copy
        lexical_variant_copy.save!
      end

      copy.reload
    end

    def parent()
      return unless parent_id
      Node.find(parent_id)
    end

    def parent=(node)
      self.update_attributes(:parent_id => node.id)
    end

    def children(select_params = '')
      select_params = select_params.empty? ? '`nodes`.*' : select_params.split(',').map { |p| '`nodes`.' + p.strip }.join(', ')
      nodes = Node.select(select_params)
        .where(:parent_id => id)
        .joins(:name)
        .order("name_string")
        .readonly(false) #select and join return readonly objects, override that here
      nodes
    end

    def has_children?
      Node.select(:id).where(:parent_id => id).limit(1).exists?
    end

    def child_count
      Node.select(:id).where(:parent_id => id).size
    end

    def ancestors(options = {})
      node, nodes = self, []
      nodes << node = node.parent while node.parent
      nodes.pop unless options[:with_tree_root]
      nodes.reverse
    end

    def destroy_with_children
      nodes_to_delete = [id]
      collect_children_to_delete(nodes_to_delete)
      Node.transaction do
        nodes_to_delete.each_slice(Gnite::Config.batch_size) do |ids|
          delete_nodes_records(ids)
        end
      end
    end

    def descendants
      nodes = []
      children.each do |child|
        nodes << child.descendants
      end
    end

    #called externally, so it has to be public
    def collect_children_to_delete(nodes_to_delete)
      children('id').each do |c|
        nodes_to_delete << c.id
        c.collect_children_to_delete(nodes_to_delete)
      end
    end
    
    def delete_softly
      self.parent_id = self.tree.deleted_tree.root.id
      self.tree_id = self.tree.deleted_tree.id
      save!
      self.descendants.each do |descendant|
        descendant.tree_id = self.tree.deleted_tree.id
        descendant.save!
      end
    end

    def restore(restore_parent)
      self.parent_id = restore_parent.id
      self.tree_id = restore_parent.tree.id
      save!
      self.descendants.each do |descendant|
        descendant.tree_id = restore_parent.tree.id
        descendant.save!
      end
    end

    private
    
    def delete_nodes_records(ids)
      delete_ids = ids.join(',')
      %w{vernacular_names synonyms}.each do |table|
        Node.connection.execute("
          DELETE
          FROM #{table}
          WHERE node_id IN (#{delete_ids})")
      end
      Node.connection.execute("DELETE FROM lexical_variants WHERE lexicalable_id IN (#{delete_ids})")
      Node.connection.execute("DELETE FROM nodes WHERE id IN (#{delete_ids})")
    end
 
  end
end
