class MasterTreesController < ApplicationController
  before_filter :authenticate

  def index
    @master_trees = current_user.master_trees.by_title
  end

  def new
    @master_tree = MasterTree.new(:title => 'New Master Tree')
    @master_tree.user = current_user
    @master_tree.save

    redirect_to master_tree_url(@master_tree.id)
  end

  def show
    @master_tree = MasterTree.find(params[:id])
  end

  def edit
    @master_tree = MasterTree.find(params[:id])
  end

  def update
    @master_tree = MasterTree.find(params[:id])
    @master_tree.update_attributes(params[:master_tree])
    if @master_tree.save
      flash[:success] = "Master Tree successfully updated"
      redirect_to master_tree_url(@master_tree.id)
    else
      render :edit
    end
  end

  def destroy
    @master_tree = MasterTree.find(params[:id])
    if @master_tree.destroy
      redirect_to :action => :index
      flash[:notice] = 'Tree deleted successfully'
    end
  end

end
