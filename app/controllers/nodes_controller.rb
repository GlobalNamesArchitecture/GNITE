class NodesController < ApplicationController
  before_filter :authenticate

  def index
    respond_to do |format|
      format.json do
        tree_id = params[:master_tree_id] || params[:reference_tree_id]
        if params[:master_tree_id]
          tree = current_user.master_trees.find(tree_id)
        else
          tree = current_user.reference_trees.find(tree_id)
        end
        nodes = tree.children_of(params[:parent_id])
        render :json => NodeJsonPresenter.present(nodes)
      end
    end
  end

  def create
    respond_to do |format|
      format.json do
        node_attributes = params[:node].merge(:tree_id => params[:master_tree_id])
        node = Node.new(node_attributes)

        node.save
        render :json => node
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        node_attributes = params[:node].merge(:tree_id => params[:master_tree_id])
        node = Node.find(params[:id])
        node.update_attributes(node_attributes)

        node.save
        render :json => node
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        Node.destroy(params[:id])
        head :ok
      end
    end
  end
end
