class NodesController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        tree = current_user.trees.find(params[:tree_id])
        nodes = tree.children_of(params[:parent_id])
        render :json => NodeJsonPresenter.present(nodes)
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

  def update
    respond_to do |format|
      format.json do
        node_attributes = params[:node].merge(:tree_id => params[:tree_id])
        node = Node.find(params[:id])
        node.update_attributes(node_attributes)

        node.save
        render :json => node
      end
    end
  end

end
