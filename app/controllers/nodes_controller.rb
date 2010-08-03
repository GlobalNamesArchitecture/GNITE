class NodesController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        nodes = current_user.trees.find(params[:tree_id]).nodes

        node_hashes = nodes.map do |node|
          node_hash = {
            :data => node.name,
            :attr => { :id => node.id }
          }
        end

        render :json => node_hashes
      end
    end
  end

  def create
    respond_to do |format|
      format.json do
        node_attributes = params[:node].merge(:tree_id => params[:tree_id])
        node = Node.new(node_attributes)

        node.save
        render :json => node, :status => :created
      end
    end
  end

end
