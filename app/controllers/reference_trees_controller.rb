class ReferenceTreesController < ApplicationController
  before_filter :authenticate

  def create
    respond_to do |format|
      format.json do
        tree_params     = params[:reference_tree]
        node_list       = params[:nodes_list]
        @reference_tree = ReferenceTree.create_from_list(tree_params, node_list)

        render :partial => 'reference_tree'
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        @reference_tree = ReferenceTree.find(params[:id])
        if @reference_tree.importing?
          head :no_content
        else
          render :partial => 'reference_tree'
        end
      end
      format.html { head :bad_request }
    end
  end
end
