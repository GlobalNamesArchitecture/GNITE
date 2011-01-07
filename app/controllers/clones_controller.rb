class ClonesController < ApplicationController
  before_filter :authenticate

  def create
    node = Node.find_by_id_for_user(params[:node_id], current_user)
    tree = current_user.master_trees.find(params[:master_tree_id])

    clone = node.deep_copy_to(tree)
    clone.attributes = params[:node]
    clone.save

    render :json => clone.to_json
  end
  
end
