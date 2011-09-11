class MasterTreeLogsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @master_tree = MasterTree.find(params[:master_tree_id])
    if cannot? :show, @master_tree
      flash[:error] = "Access denied."
      redirect_to root_url
    else
      page = (params[:page]) ? params[:page] : 1
      @logs = MasterTreeLog.includes(:user)
                           .where(:master_tree_id => params[:master_tree_id])
                           .paginate(:page => page, :per_page => 25)
                           .order("updated_at DESC")
    end
  end

end