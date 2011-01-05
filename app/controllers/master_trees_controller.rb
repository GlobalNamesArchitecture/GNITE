class MasterTreesController < ApplicationController
  before_filter :authenticate

  def index
    @master_trees = current_user.master_trees.by_title
  end

  def new
    @master_tree = MasterTree.new(:title => 'New Master Tree')
    @master_tree.user = current_user
    @master_tree.save
    
    @deleted_tree = DeletedTree.new(:title => 'Deleted Names', :master_tree_id => @master_tree.id)
    @deleted_tree.user = current_user
    @deleted_tree.save

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
      if request.xhr?
        render :json => { :status => "OK"}
      else
        flash[:success] = "Master Tree successfully updated"
        redirect_to master_tree_url(@master_tree.id)
      end
    else
      render :edit
    end
  end

  def destroy
    @master_tree = MasterTree.find(params[:id])
    @deleted_tree = DeletedTree.find_by_master_tree_id(params[:id])
    if @master_tree.destroy && @deleted_tree.destroy
      flash[:notice] = 'Tree deleted successfully'
      redirect_to :action => :index
    end
  end

end
