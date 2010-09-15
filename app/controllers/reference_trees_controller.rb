class ReferenceTreesController < ApplicationController

  def create
    respond_to do |format|
      format.json do
        tree_params = params[:reference_tree].merge(:user_id => current_user.id)
        node_list = params[:nodes_list]
        reference_tree = ReferenceTree.create_from_list(tree_params, node_list)
        render :json => reference_tree
      end
    end
  end

  def show
    @reference_tree = ReferenceTree.find(params[:id])
    respond_to do |format|
      format.html
      format.json do
        if @reference_tree.importing?
          head :no_content
        else
          render :partial => 'reference_tree'
        end
      end
    end
  end
end
