class ApplicationController < ActionController::Base
  
  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end
  
  layout 'application'

  private

  def get_tree
    tree_id = params[:master_tree_id] || params[:reference_tree_id] || params[:deleted_tree_id] || params[:merge_tree_id]

    if params[:master_tree_id]
      tree = MasterTree.find(tree_id) rescue nil
      tree = nil unless can? :show, tree
    elsif params[:reference_tree_id]
      tree = ReferenceTree.find(tree_id) rescue nil
    elsif params[:deleted_tree_id]
      tree = DeletedTree.find(tree_id) rescue nil
    elsif params[:merge_tree_id]
      tree = MergeTree.find(tree_id) rescue nil
    else
      tree = nil unless tree.master_tree.users.find(current_user)
    end
    tree
  end
  
  def schedule_action(node, master_tree, params)

    raise "Unknown action command" unless params[:action_type] && Gnite::Config.action_types.include?(params[:action_type])
    tree_id = master_tree.id
    destination_parent_id = (params[:node] && params[:node][:parent_id]) ? params[:node][:parent_id] : nil
    destination_parent_id = (params[:node] && params[:node][:destination_parent_id]) ? params[:node][:destination_parent_id] : destination_parent_id
    destination_node_id = (params[:node] && params[:node][:destination_node_id]) ? params[:node][:destination_node_id] : nil
    parent_id = node.is_a?(::Node) ? node.parent_id : params[:node][:parent_id]
    node_id = node.is_a?(::Node) ? node.id : nil
    old_name = node.is_a?(::Node) ? node.name.name_string : nil
    new_name = (params[:node] && params[:node][:name] && params[:node][:name][:name_string]) ? params[:node][:name][:name_string] : nil
    json_message = (params[:json_message]) ? params[:json_message].to_json : nil
    action_class = Object.class_eval(params[:action_type])
    action_command = action_class.create!(:user => current_user, 
      :tree_id => tree_id, :node_id => node_id, 
      :old_name => old_name, :new_name => new_name,
      :destination_node_id => destination_node_id,
      :destination_parent_id => destination_parent_id, 
      :parent_id => parent_id, :json_message => json_message)

    ActionCommand.schedule_actions(action_command, request.headers["X-Session-ID"])
    action_command.reload
  end
  
  def push_metadata_message(channel, action)
    Juggernaut.publish(channel, "{ \"subject\" : \"metadata\", \"action\" : #{action.serializable_hash.to_json} }", :except => request.headers["X-Session-ID"]);
  end

end
