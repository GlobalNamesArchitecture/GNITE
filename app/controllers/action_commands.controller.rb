class ActionCommandsController < ApplicationController
  before_filter :authenticate
  
  def index
    page = (params[:page]) ? params[:page] : 1
    @logs = ActionCommand.where(:tree_id => params[:master_tree_id])
                         .order("updated_at DESC")
                         .paginate(:page => page, :per_page => 30)
                 
    render :partial => 'action_command'
  end

end