class ImportsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @master_tree = current_user.master_trees.find(params[:master_tree_id])
    render :layout => 'right_tree'
  end
end
