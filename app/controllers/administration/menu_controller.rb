class Administration::MenuController < ApplicationController
  before_filter :authenticate_user!
  
  layout "master_trees"
  
  def show
    if !current_user.has_role? :admin
      flash[:error] = "You do not have permission to access this page"
      redirect_to root_url
    end
    
  end

end