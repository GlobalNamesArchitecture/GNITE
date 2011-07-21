class SynonymsController < ApplicationController
  before_filter :authenticate
  
  def create
    name        = Name.find_or_create_by_name_string(params[:name_string])
    #TODO need UI to select the synonym type
    @synonym    = Synonym.new(:name => name, :node_id => params[:node_id], :type => 'synonym')
    @synonym.save

    respond_to do |format|
      format.json do
        render :json => @synonym
      end
    end
    
  end
  
  def update
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    node        = master_tree.nodes.find(params[:node_id])
    @synonym    = node.synonyms.find(params[:id])
    @synonym.rename(params[:name_string])
    respond_to do |format|
      format.json do
        render :json => @synonym
      end
    end
  end
  
  def destroy
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    node        = master_tree.nodes.find(params[:node_id])
    synonym     = node.synonyms.find(params[:id])
    synonym.destroy
    
    respond_to do |format|
      format.json do
        render :json => { :status => "OK" }
      end
    end
  end

end