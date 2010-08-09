class TreesController < ApplicationController

  def index
    @trees = current_user.trees
  end

  def new
    @tree = Tree.new
  end

  def create
    @tree = Tree.new(params[:tree])
    @tree.user = current_user
    if @tree.save
      flash[:success] = "Tree successfully created"
      redirect_to tree_url(@tree.id)
    else
      render :new
    end
  end

  def show
    @tree = Tree.find(params[:id])
  end

  def edit
    @tree = Tree.find(params[:id])
  end

  def update
    @tree = Tree.find(params[:id])
    @tree.update_attributes(params[:tree])
    if @tree.save
      flash[:success] = "Tree successfully updated"
      redirect_to tree_url(@tree.id)
    else
      render :edit
    end
  end
end
