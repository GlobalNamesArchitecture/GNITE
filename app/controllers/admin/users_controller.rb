class Admin::UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    page = (params[:page]) ? params[:page] : 1
    @users = User.find(:all, :order => :surname).paginate(:page => page, :per_page => 25)
  end

  def show
    render :index
  end

end