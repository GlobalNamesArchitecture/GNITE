class ClonesController < ApplicationController
  before_filter :authenticate

  def create
    tree = current_user.master_trees.find(params[:master_tree_id])
    node = tree.nodes.find(params[:node_id])
    clone = node.deep_copy
    clone.attributes = params[:node]
    clone.save

    render :json => clone.to_json, :status => :created
  end

end

