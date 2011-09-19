class ReferenceTreesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

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
        if @reference_tree.importing?
          head :no_content
        else
          render :partial => 'reference_tree'
        end
      end
      format.html { head :bad_request }
    end
  end
  
  def destroy
    master_tree = MasterTree.find(params[:master_tree_id]) rescue nil
    if master_tree.users.include?(current_user)
      collection_count = @reference_tree.reference_tree_collections.count
      ReferenceTreeCollection.destroy_all(:master_tree_id => master_tree.id, :reference_tree_id => @reference_tree.id)
      if collection_count == 1
        @reference_tree.nuke
      end
    end
    render :json => @reference_tree
  end

end
