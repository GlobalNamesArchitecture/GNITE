class NodesController < ApplicationController
  before_filter :authenticate

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

    render :json => {
      :name             => node.name_string,
      :rank             => node.rank_string,
      :synonyms         => node.synonym_data,
      :vernaculars      => node.vernacular_data
    }
  end

  def create
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    if params[:nodes_list] && params[:nodes_list][:data].size
      @names = params[:nodes_list][:data].split("\n")
      @names.each do |name|
        params[:node][:name][:name_string] = name
        action_command = schedule_action(nil, params)
      end
      respond_to do |format|
        format.json do
          render :json => { :status => "OK" }
        end
      end
    else
      params[:node][:parent_id] = master_tree.root.id unless params[:node] && params[:node][:parent_id]
      #node will exist if we create a new node by copy from a reference tree
      #TODO: if node was dragged from reference to master 2+ times, it will fail because of a duplicate key in nodes table on 'index_nodes_on_local_id_and_tree_id'
      node = params[:node] && params[:node][:id] ? Node.find(params[:node][:id]) : nil
      action_command = schedule_action(node, params)
      respond_to do |format|
        format.json do
          render :json => action_command.json_message
        end
      end
    end
  end

  def update
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    node        = master_tree.nodes.find(params[:id])
    respond_to do |format|
      format.json do
        schedule_action(node, params)
        render :json => node.reload
      end
    end
  end

  private

  def schedule_action(node, params)

    raise "Unknown action command" unless params[:action_type] && Gnite::Config.action_types.include?(params[:action_type])

    destination_parent_id = (params[:node] && params[:node][:parent_id]) ? params[:node][:parent_id] : nil
    parent_id = node.is_a?(::Node) ? node.parent_id : params[:node][:parent_id]
    node_id = node.is_a?(::Node) ? node.id : nil
    old_name = node.is_a?(::Node) ? node.name.name_string : nil
    new_name = (params[:node] && params[:node][:name] && params[:node][:name][:name_string]) ? params[:node][:name][:name_string] : nil

    action_command = eval("#{params[:action_type]}.create!(:user => current_user, :node_id => node_id, :old_name => old_name, :new_name => new_name, :destination_parent_id => destination_parent_id, :parent_id => parent_id)")

    ActionCommand.schedule_actions(action_command, request.headers["X-Session-ID"])
    action_command.reload
  end
end
