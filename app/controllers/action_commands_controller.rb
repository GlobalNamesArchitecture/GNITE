class ActionCommandsController < ApplicationController
  before_filter :authenticate
  
  def index
    @master_tree = MasterTree.find(params[:master_tree_id])
    
    page = (params[:page]) ? params[:page] : 1
    @logs = ActionCommand.where(:tree_id => params[:master_tree_id])
                         .order("updated_at DESC")
                         .paginate(:page => page, :per_page => 25)

    @messages = @logs.map do |log|
      ac = ActionCommand.find(log.id)
      message = {
        :message => ac.get_log,
        :user    => log.user.email,
        :updated => log.updated_at,
        :undone  => log.undo 
      }
    end
    
  end

end