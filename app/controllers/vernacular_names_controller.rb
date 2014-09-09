class VernacularNamesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_authorize_resource only: :create
  
  def create
    node = Node.find(params[:node_id]) rescue nil
    
    if cannot? :update, node
      flash[:error] = "Access denied."
      redirect_to root_url
    else
      channel     = "tree_#{params[:master_tree_id]}"
      name        = Name.find_or_create_by(name_string: params[:name_string])
      @vernacular = VernacularName.new(name: name, node_id: params[:node_id])
      @vernacular.save
      
      push_metadata_message(channel, @vernacular)

      respond_to do |format|
        format.json do
          render json: @vernacular
        end
      end
    end
  end
  
  def update
    channel     = "tree_#{params[:master_tree_id]}"
    master_tree = MasterTree.find(params[:master_tree_id]) rescue nil
    node        = master_tree.nodes.find(params[:node_id]) rescue nil
    @vernacular = node.vernacular_names.find(params[:id]) rescue nil
    if(params[:language_id])
      @vernacular.update_attributes(language_id: params[:language_id])
      @vernacular.save
    end
    if(params[:name_string])
      @vernacular.rename(params[:name_string])
    end
    
    push_metadata_message(channel, @vernacular)
    
    respond_to do |format|
      format.json do
        render json: @vernacular
      end
    end
  end
      
  def destroy
    channel     = "tree_#{params[:master_tree_id]}"
    master_tree = MasterTree.find(params[:master_tree_id]) rescue nil
    node        = master_tree.nodes.find(params[:node_id]) rescue nil
    @vernacular = node.vernacular_names.find(params[:id]) rescue nil
    @vernacular.destroy
    
    push_metadata_message(channel, @vernacular)
    
    respond_to do |format|
      format.json do
        render json: @vernacular
      end
    end
  end

end