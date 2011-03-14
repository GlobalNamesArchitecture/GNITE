class NodesController < ApplicationController
  before_filter :authenticate

  def index
    respond_to do |format|
      format.json do
        tree_id = params[:master_tree_id] || params[:reference_tree_id] || params[:deleted_tree_id]
        if params[:master_tree_id]
          tree = current_user.master_trees.find(tree_id)
        elsif params[:reference_tree_id]
          tree = current_user.reference_trees.find(tree_id)
        else
          tree = current_user.deleted_trees.find(tree_id)
        end
        parent_id = params[:parent_id] ? params[:parent_id] : tree.root
        nodes = tree.children_of(parent_id)
        render :json => NodeJsonPresenter.present(nodes)
      end
    end
  end

  def show
    tree_id = params[:master_tree_id] || params[:reference_tree_id] || params[:deleted_tree_id]

    if params[:master_tree_id]
      tree = current_user.master_trees.find(tree_id)
    elsif params[:reference_tree_id]
      tree = current_user.reference_trees.find(tree_id)
    else
      tree = current_user.deleted_trees.find(tree_id)
    end

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
    tree_queue = action_command.master_tree ? "gnite_action_tree_#{action_command.master_tree.id}" : (raise "what master tree?")
    eval("#{params[:action_type]}.queue = '#{tree_queue}'")
    Resque.enqueue(eval(params[:action_type]), action_command.id)
    eval("#{params[:action_type]}.queue = nil")

    workers = Resque.workers.select {|w| w.queues.include?(tree_queue) }
    raise "More than one worker for the #{tree_queue}!" if workers.size > 1
    if workers.empty?
      workers = [Resque::Worker.new(tree_queue)]
    end
    worker = workers[0]
    jobs_left = true
    while jobs_left
      jobs_left = worker.process #TODO! Check if this is executing jobs in sequence!!!
    end
    action_command.reload
  end
end
