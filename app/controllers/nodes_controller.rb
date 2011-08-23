class NodesController < ApplicationController
  before_filter :authenticate_user!

  def index
    respond_to do |format|

      raise "Child node cannot be rendered" unless (params[:parent_id].to_i > 0 or !params[:parent_id])

      tree = get_tree
      parent_id = params[:parent_id] ? params[:parent_id] : tree.root
      @nodes = tree.children_of(parent_id)

      format.json do
        render :json => NodeJsonPresenter.present(@nodes)
      end

      format.xml do
        response.headers['Content-type'] = 'text/xml; charset=utf-8'
        render :layout => false
      end

      format.html do
        response.headers['Content-type'] = 'text/html; charset=utf-8'
        render :layout => false
      end

    end
  end

  def show
    tree = get_tree
    node = tree.nodes.find(params[:id])
    
    @metadata = {
      :id          => node.id,
      :name        => node.name_string,
      :rank        => node.rank_string,
      :synonyms    => node.synonym_data,
      :vernaculars => node.vernacular_data
    }
    
    respond_to do |format|
      format.json do
        render :json => @metadata
      end
      
      format.html do
        if params[:master_tree_id]
          tree_type = 'MasterTree'
        elsif params[:reference_tree_id]
          tree_type = 'ReferenceTree'
        end
        render :partial => 'shared/metadata', :locals => { :tree_type => tree_type }
      end
    end

  end

  def create
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    params[:node][:parent_id] = master_tree.root.id unless params[:node] && params[:node][:parent_id]
    node = params[:node] && params[:node][:id] ? Node.find(params[:node][:id]) : nil
    action_command = schedule_action(node, master_tree, params)
    respond_to do |format|
      format.json do
        render :json => action_command.json_message
      end
    end
  end

  def update
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    node        = master_tree.nodes.find(params[:id])
    respond_to do |format|
      format.json do
        schedule_action(node, master_tree, params)
        render :json => node.reload
      end
    end
  end
end
