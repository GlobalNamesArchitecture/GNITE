class ActionCommand < ActiveRecord::Base
  belongs_to :user

  def self.queue
    @queue_name
  end

  def self.queue=(queue_name)
    @queue_name = queue_name
  end

  def self.perform(instance_id)
    ac = ActionCommand.find(instance_id)
    if ac.undo?
      ac.precondition_undo ?  perform_undo(ac) : ac.precondition_undo_error
    else
      ac.precondition_do ?  perform_do(ac) : ac.precondition_do_error
    end
    ac.save!
  end

  def self.schedule_actions(action_command, session_id)
    
    master_tree = action_command.master_tree
    tree_queue = master_tree ? "gnite_action_tree_#{master_tree.id}" : (raise "Cannot determine master tree in the action_command")
    channel = "tree_#{master_tree.id}"
    action_command.class.queue = tree_queue
    
    master_tree.state = 'working'
    master_tree.save
    
    Juggernaut.publish(channel, "{ \"subject\" : \"edit\", \"message\" : #{action_command.serializable_hash(:except => :json_message).to_json} }", :except => session_id)
    Juggernaut.publish(channel, "{ \"subject\" : \"lock\" }", :except => session_id)
    
    Resque.enqueue(action_command.class, action_command.id)
    action_command.class.queue = nil

    workers = Resque.workers.select {|w| w.queues.include?(tree_queue) }
    raise "More than one worker for the #{tree_queue}!" if workers.size > 1
    if workers.empty?
      workers = [Resque::Worker.new(tree_queue)]
    end
    worker = workers[0]
    worker.register_worker
    while Resque.size(tree_queue) > 0
      worker.process #TODO! Check if this is executing jobs in sequence!!!
    end
    
    master_tree.state = 'active'
    master_tree.save
    
    Juggernaut.publish(channel, "{ \"subject\" : \"unlock\" }")
    
  end

  def precondition_do
    raise_not_implemented
  end

  def precondition_undo
    precondition_do
  end

  def raise_not_implemented
    raise "Implement in your child class"
  end

  def undo_action
    raise_not_implemented
  end

  def do_action
    raise_not_implemented
  end

  def precondition_do_error
    raise Gnite::ActionPreconditionsError, "Preconditions are not met"
  end

  def precondition_undo_error
    precondition_do_error
  end

  def ancestry_ok?(a_node)
    ancestors = a_node.ancestors(:with_tree_root => true) + [a_node]
    ancestors.size == 1 || (ancestors.map {|a| a.tree_id}.uniq.size == 1 && ancestors.first.parent_id == nil)
  end

  def node
    return nil unless node_id
    @node = defined?(@node) ? @node : Node.find(node_id)
  end

  def master_tree
    begin
      node.tree
    rescue NoMethodError
      nil
    end
  end

  private

  def self.perform_undo(action_command)
    action_command.undo_action
    action_command.undo = false
    undo_actions = UndoActionCommand.where(:master_tree_id => action_command.master_tree.id, :action_command_id => action_command.id)
    RedoActionCommand.create(:master_tree_id => action_command.master_tree.id, :action_command_id => action_command.id)
    undo_actions[0].destroy unless undo_actions.empty?
  end

  def self.perform_do(action_command)
    action_command.do_action
    action_command.undo = true
    redo_action = RedoActionCommand.where(:master_tree_id => action_command.master_tree.id, :action_command_id => action_command.id)
    if redo_action.empty?
      RedoActionCommand.connection.execute("delete from redo_action_commands where master_tree_id = #{action_command.master_tree.id}")
    else
      redo_action[0].destroy
    end
    UndoActionCommand.create(:master_tree => action_command.master_tree, :action_command => action_command)
  end
end
