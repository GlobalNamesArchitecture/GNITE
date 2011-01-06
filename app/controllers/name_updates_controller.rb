class NameUpdatesController < ApplicationController
  before_filter :authenticate

  def create
    success = false
    respond_to do |format|
      format.json do
        master_tree = current_user.master_trees.find(params[:master_tree_id])
        node = Node.where(:tree_id => master_tree.id, :id => params[:node_id]).limit(1).first
        name = Name.where(:name_string => params[:name][:name_string]).limit(1).first || Name.create(:name_string => params[:name][:name_string]) 
        if name.is_a?(Name) && node.is_a?(Node)
          node.name = name 
          success = node.save
        end
        head(success ? :ok : :error)
      end
    end
  end
end
