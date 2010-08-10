class ClonesController < ApplicationController
  before_filter :authenticate

  def create
    tree = current_user.trees.find(params[:tree_id])
    node = tree.nodes.find(params[:node_id])
    clone = node.clone
    clone.attributes = params[:node]
    clone.save

    render :json => clone.to_json, :status => :created
  end

end

