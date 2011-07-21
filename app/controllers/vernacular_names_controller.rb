class VernacularNamesController < ApplicationController
  before_filter :authenticate
  
  def create
    name     = Name.find_or_create_by_name_string(params[:name_string])
    #TODO Need UI to select language
    language = Language.find_by_name('English')
    @vernacular    = VernacularName.new(:name => name, :node_id => params[:node_id], :language => language)
    @vernacular.save

    respond_to do |format|
      format.json do
        render :json => @vernacular
      end
    end
  end
  
  def update
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    node        = master_tree.nodes.find(params[:node_id])
    @vernacular = node.vernacular_names.find(params[:id])
    @vernacular.rename(params[:name_string])
    respond_to do |format|
      format.json do
        render :json => @vernacular
      end
    end
  end
  
  def destroy
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    node        = master_tree.nodes.find(params[:node_id])
    vernacular  = node.vernacular_names.find(params[:id])
    vernacular.destroy
    
    respond_to do |format|
      format.json do
        render :json => { :status => "OK" }
      end
    end
  end

end