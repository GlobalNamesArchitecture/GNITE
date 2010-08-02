class NodesController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        # root = Node.find(params[:parent_id]) rescue nil
        # nodes = root ? root.children : Node.roots
        nodes = current_user.trees.find(params[:tree_id]).nodes

        node_hashes = nodes.map do |node|
          node_hash = {
            :data => node.name,
            :attr => { :id => node.id }
          }

          # node_hash[:state] = 'closed' if node.has_children?
          # node_hash
        end

        render :json => node_hashes
      end
    end
  end

  # prototype:
  #
  def create
    respond_to do |format|
      format.json do
        node_attributes = params[:node].merge(:tree_id => params[:tree_id])
        node = Node.new(node_attributes)

        # if
        node.save
        render :json => node, :status => :created
        #else
        #  render :json => node.errors, :status => :unprocessable_entity
        #end
      end
    end
  end

end
