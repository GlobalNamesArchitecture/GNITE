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
          tree = current_user.deleted_tree.find(tree_id)
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
      tree = current_user.deleted_tree.find(tree_id)
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
    schedule_action(nil, params)
    respond_to do |format|
      format.json do
        render :json => 'OK'
      end
    end
  end

  def update
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    node        = master_tree.nodes.find(params[:id])
    respond_to do |format|
      format.json do
        if params[:action_type] && Gnite::Config.action_types.include?(params[:action_type])
          schedule_action(node, params)
        else
          node.update_attributes(params[:node])
        end
        render :json => node
      end
    end
  end

  def destroy
    # deleted_tree    = current_user.deleted_tree.find_by_master_tree_id(params[:master_tree_id])
    # master_tree     = current_user.master_trees.find(params[:master_tree_id])
    # root_node       = master_tree.nodes.find(params[:id])
    # 
    # root_node.update_attributes(:parent_id => nil, :tree_id => deleted_tree.id)
    #     
    # root_node.descendants.each do |descendant|
    #   node = master_tree.nodes.find_by_id(descendant.id)
    #   node.update_attributes(:tree_id => deleted_tree.id)
    # end
    #     
    # head :ok
    respond_to do |format|
      format.json do
       Node.destroy(params[:id])
       head :ok
      end
    end
  end

  private
  
  def schedule_action(node, params)
    raise "Unknown action command" unless params[:action_type] && Gnite::Config.action_types.include?(params[:action_type])
    
    destination_parent_id = (params[:node] && params[:node][:parent_id]) ? params[:node][:parent_id] : nil
    node_id = node.is_a?(::Node) ? node.id : nil
    old_name = node.is_a?(::Node) ? node.name.name_string : nil
    new_name = (params[:node] && params[:node][:name] && params[:node][:name][:name_string]) ? params[:node][:name][:name_string] : nil
    parent_id = node.is_a?(::Node) ? node.parent_id : params[:node][:parent_id]
    
    action_command = eval("#{params[:action_type]}.create!(:user => current_user, :node_id => node_id, :old_name => old_name, :new_name => new_name, :destination_parent_id => destination_parent_id, :parent_id => parent_id)")

    Resque.enqueue(eval(params[:action_type]), action_command.id)
    workers = Resque.workers.select {|w| w.queues.include?(Gnite::Config.action_queue.to_s) }
    raise "More than one worker for the #{Gnite::Config.action_queue}!" if workers.size > 1
    raise "No worker for #{Gnite::Config.action_queue}!" if workers.empty?
    jobs_left = true
    while jobs_left
      jobs_left = workers[0].process
    end
  end
end
