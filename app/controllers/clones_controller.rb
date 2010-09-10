class ClonesController < ApplicationController
  before_filter :authenticate

  def create
    node = Node.find_by_id_for_user(params[:node_id], current_user)
    clone = node.deep_copy
    clone.attributes = params[:node]
    clone.tree_id = params[:master_tree_id]
    clone.save

    render :json => clone.to_json
  end

end
