class MasterTreesController < ApplicationController
  before_filter :authenticate

  def index
    @master_trees = current_user.master_trees
  end

  def new
    @master_tree = MasterTree.new
  end

  def create
    @master_tree = MasterTree.new(params[:master_tree])
    @master_tree.user = current_user

    if @master_tree.save
      flash[:success] = "Master Tree successfully created"
      redirect_to master_tree_url(@master_tree.id)
    else
      render :new
    end
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
end
