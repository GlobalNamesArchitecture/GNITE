class NameUpdatesController < ApplicationController
  before_filter :authenticate

  def create
    respond_to do |format|
      format.json do
        master_tree = current_user.master_trees.find(params[:master_tree_id])
        node        = master_tree.nodes.find(params[:node_id])
        name        = node.name
        if name.used_only_once?
          name.name_string!(params[:name][:name_string])
        end
      end
    end
    head :ok
  end
end
