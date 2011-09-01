class ReferenceTreesController < ApplicationController
  before_filter :authenticate_user!

  def create
    respond_to do |format|
      format.json do
        node_list       = params[:nodes_list]
        revision = Digest::SHA1.hexdigest(params['nodes_list'].to_s)
        tree_params     = params[:reference_tree].merge!(:revision => revision, :publication_date => Time.now)
        master_tree = MasterTree.find(params[:reference_tree][:master_tree_id])
        @reference_tree = ReferenceTree.create_from_list(tree_params, node_list)
        ReferenceTreeCollection.create!(:master_tree => master_tree, :reference_tree => @reference_tree)
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
