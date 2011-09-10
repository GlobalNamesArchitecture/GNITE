class Admin::UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def index
    page = (params[:page]) ? params[:page] : 1
    @users = User.find(:all, :order => :surname).paginate(:page => page, :per_page => 25)
  end
  
  def show
    redirect_to :edit_admin_user
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.confirmed_at = Time.now()
    if @user.save
      flash[:notice] = "Successfully created User." 
      #todo send email to user
      redirect_to admin_users_path
    else
      render :action => 'new'
    end
  end
  
  def update
    @user = User.find(params[:id])   
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
    end
    render :action => 'edit'
  end

end