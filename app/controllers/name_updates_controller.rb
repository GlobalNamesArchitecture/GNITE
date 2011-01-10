class NameUpdatesController < ApplicationController
  before_filter :authenticate

  def create
    success = false
    respond_to do |format|
      format.json do
        master_tree = current_user.master_trees.find(params[:master_tree_id])
        node = Node.find(params[:node_id])
        success = node ? node.rename(params[:name][:name_string]) : false
        head(success ? :ok : :error)
      end
    end
  end
end
