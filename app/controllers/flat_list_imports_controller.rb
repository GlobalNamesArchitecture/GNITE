class FlatListImportsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @master_tree = MasterTree.find(params[:master_tree_id])
    render layout: 'right_tree'
  end
end
