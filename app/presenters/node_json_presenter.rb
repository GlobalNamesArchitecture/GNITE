class NodeJsonPresenter
  def self.present(nodes)
    node_hashes = nodes.map do |node|
      node_hash = {
        :data => node.name,
        :attr => { :id => node.id }
      }
      node_hash[:state] = 'closed' if node.has_children?
      node_hash
    end

    node_hashes.to_json
  end
end
