class NameUpdatesController < ApplicationController
  before_filter :authenticate

  def create
    success = false
    respond_to do |format|
      format.json do
        master_tree = current_user.master_trees.find(params[:master_tree_id])
        node = Node.find(params[:node_id])
        arn = ActionRenameNode.create!(:user => current_user, :node_id => node.id, :old_name => node.name.name_string, :new_name => params[:name][:name_string])
        Resque.enqueue(ActionRenameNode, arn.id)
        workers = Resque.workers.select {|w| w.queues.include?(Gnite::Config.action_queue.to_s) }
        raise "More than one worker for the #{Gnite::Config.action_queue}!" if workers.size > 1
        raise "No worker for #{Gnite::Config.action_queue}!" if workers.empty?
        jobs_left = true
        while jobs_left
          jobs_left = workers[0].process
        end
        head :ok
      end
    end
  end
end
