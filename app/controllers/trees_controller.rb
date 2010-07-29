class TreesController < ApplicationController
  def index
    @trees = current_user.trees
  end

  def new
    @tree = Tree.new
  end

  def create
    @tree = Tree.new(params[:tree])
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
end
