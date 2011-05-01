class TreeSearchJsonPresenter
  def self.present(nodes)
    
    node_hashes = nodes.map do |node|
      treepath_strings = []
      treepath_ids = []
      
      node.ancestors.each do |ancestor|
        treepath_strings << ancestor.name_string
        treepath_ids << "#" + ancestor.id.to_s
      end
      
      treepath_strings << node.name_string
      treepath_ids << "#" + node.id.to_s
      
      node_hash = {
        :name => node.name_string,
        :id => node.id,
        :treepath => {
          :name_strings => treepath_strings.join(' > '),
          :node_ids => treepath_ids
        }
      }

      end

    node_hashes.to_json
    
  end
end