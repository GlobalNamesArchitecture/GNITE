class MasterTreeLogsController < ApplicationController
  
  def index
    @master_tree = MasterTree.find(params[:master_tree_id])
    
    page = (params[:page]) ? params[:page] : 1
    @logs = MasterTreeLog.where(:master_tree_id => params[:master_tree_id])
                         .order("updated_at DESC")
                         .paginate(:page => page, :per_page => 25)
    
  end

end