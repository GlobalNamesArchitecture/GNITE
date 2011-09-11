class SynonymsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_authorize_resource :only => :create
  
  def create
    node = Node.find(params[:node_id]) rescue nil
    
    if cannot? :update, node
      flash[:error] = "Access denied."
      redirect_to root_url
    else
      channel     = "tree_#{params[:master_tree_id]}"
      name        = Name.find_or_create_by_name_string(params[:name_string])
      @synonym    = Synonym.new(:name => name, :node_id => params[:node_id], :status => 'synonym')
      @synonym.save
      
      push_metadata_message(channel, @synonym)

      respond_to do |format|
        format.json do
          render :json => @synonym
        end
      end
    end
    
  end
  
  def update
    channel     = "tree_#{params[:master_tree_id]}"
    master_tree = MasterTree.find(params[:master_tree_id]) rescue nil
    node        = master_tree.nodes.find(params[:node_id]) rescue nil
    @synonym    = node.synonyms.find(params[:id]) rescue nil
    if(params[:status])
      @synonym.update_attributes(:status => params[:status])
      @synonym.save
    end
    if(params[:name_string])
      @synonym.rename(params[:name_string])
    end
    
    push_metadata_message(channel, @synonym)
    
    respond_to do |format|
      format.json do
        render :json => @synonym
      end
    end
  end
  
  def destroy
    channel     = "tree_#{params[:master_tree_id]}"
    master_tree = MasterTree.find(params[:master_tree_id]) rescue nil
    node        = master_tree.nodes.find(params[:node_id]) rescue nil
    @synonym    = node.synonyms.find(params[:id]) rescue nil
    @synonym.destroy
    
    push_metadata_message(channel, @synonym)
    
    respond_to do |format|
      format.json do
        render :json => @synonym
      end
    end    
  end

end