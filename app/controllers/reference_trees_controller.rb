class ReferenceTreesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    respond_to do |format|
      format.json do
        node_list       = params[:nodes_list]
        revision = Digest::SHA1.hexdigest(params['nodes_list'].to_s)
        tree_params     = params[:reference_tree].merge!(:revision => revision, :publication_date => Time.now)
        @master_tree = MasterTree.find(params[:reference_tree][:master_tree_id])
        @reference_tree = ReferenceTree.create_from_list(tree_params, node_list)
        ReferenceTreeCollection.create!(:master_tree => @master_tree, :reference_tree => @reference_tree)
        push_message("reference-add")
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
    @master_tree = MasterTree.find(params[:master_tree_id]) rescue nil
    if @master_tree.users.include?(current_user) || current_user.has_role?(:admin) || current_user.has_role?(:master_editor)
      collection_count = @reference_tree.reference_tree_collections.count
      ReferenceTreeCollection.destroy_all(:master_tree_id => @master_tree.id, :reference_tree_id => @reference_tree.id)
      if collection_count == 1
        @reference_tree.nuke
      end
    end
    push_message("reference-remove")
    render :json => @reference_tree
  end
  
  private
  
  def push_message(subject)
    channel = "tree_#{@master_tree.id}"
    message = { :subject => subject, :message => @reference_tree, :user => current_user, :time => Time.new.to_s }.to_json
    session_id = (request.headers["X-Session-ID"]) ? request.headers["X-Session-ID"] : ""
    Juggernaut.publish(channel, message, :except => session_id)
  end

end
