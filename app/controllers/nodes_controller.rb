class NodesController < ApplicationController
  before_filter :authenticate

  def index
    respond_to do |format|
      format.json do
        tree = get_tree
        parent_id = params[:parent_id] ? params[:parent_id] : tree.root
        nodes = tree.children_of(parent_id)
        render :json => NodeJsonPresenter.present(nodes)
      end
    end
  end

  def show
    tree = get_tree
    node = tree.nodes.find(params[:id])

    render :json => {
      :rank             => node.rank_string,
      :synonyms         => node.synonym_name_strings,
      :vernacular_names => node.vernacular_name_strings
    }
  end

  def create
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    params[:node][:parent_id] = master_tree.root.id unless params[:node] && params[:node][:parent_id]
    #node will exist if we create a new node by copy from a reference tree
    node = params[:node] && params[:node][:id] ? Node.find(params[:node][:id]) : nil
    action_command = schedule_action(node, params)
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

    ActionCommand.schedule_actions(action_command)
    action_command.reload
  end
end
