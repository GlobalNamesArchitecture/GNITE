class VernacularNamesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    name     = Name.find_or_create_by_name_string(params[:name_string])
    @vernacular    = VernacularName.new(:name => name, :node_id => params[:node_id])
    @vernacular.save

    respond_to do |format|
      format.json do
        render :json => @vernacular
      end
    end
  end
  
  def update
    master_tree = MasterTree.find(params[:master_tree_id])
    node        = master_tree.nodes.find(params[:node_id])
    @vernacular = node.vernacular_names.find(params[:id])
    if(params[:language_id])
      @vernacular.update_attributes(:language_id => params[:language_id])
      @vernacular.save
    end
    if(params[:name_string])
      @vernacular.rename(params[:name_string])
    end
    respond_to do |format|
      format.json do
        render :json => @vernacular
      end
    end
  end
      
  def destroy
    master_tree = MasterTree.find(params[:master_tree_id])
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