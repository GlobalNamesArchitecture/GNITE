class MasterTreeLogsController < ApplicationController
  before_filter :authenticate
  
  def index
    @master_tree = MasterTree.find(params[:master_tree_id])
    
    page = (params[:page]) ? params[:page] : 1
    @logs = MasterTreeLog.where(:master_tree_id => params[:master_tree_id])
                         .order("updated_at DESC")
                         .paginate(:page => page, :per_page => 25)

    @messages = @logs.map do |log|
      ac = MasterTreeLog.find(log.id)
      message = {
        :message => ac.message,
        :user    => log.user.email,
        :updated => log.updated_at 
      }
    end
    
  end

end