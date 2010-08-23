class MasterTreesController < ApplicationController

  def index
    @trees = current_user.master_trees
  end

  def new
    @tree = MasterTree.new
  end

  def create
    @tree = MasterTree.new(params[:master_tree])
    @tree.user = current_user

    if @tree.save
      flash[:success] = "Master Tree successfully created"
      redirect_to master_tree_url(@tree.id)
    else
      render :new
    end
  end

  def show
    @tree = MasterTree.find(params[:id])
  end

  def edit
    @tree = MasterTree.find(params[:id])
  end

  def update
    @tree = MasterTree.find(params[:id])
    @tree.update_attributes(params[:master_tree])
    if @tree.save
      flash[:success] = "Master Tree successfully updated"
      redirect_to master_tree_url(@tree.id)
    else
      render :edit
    end
  end
end
