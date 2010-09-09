class FlatListImportsController < ApplicationController
  before_filter :authenticate

  def new
    @master_tree = current_user.master_trees.find(params[:master_tree_id])
    render :layout => 'right_tree'
  end
end
