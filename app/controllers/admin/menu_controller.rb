class Admin::MenuController < ApplicationController
  before_filter :authenticate_user!
  
  layout "pages"
  
  def index
  end

  def show
    render :index
  end

end
