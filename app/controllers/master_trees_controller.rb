class MasterTreesController < ApplicationController
  before_filter :authenticate

  def index
    @master_trees = current_user.master_trees.by_title
  end

  def new
    @master_tree = MasterTree.new(:title => 'New Working Tree')
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
    if params[:cancel]
      redirect_to master_tree_url(params[:id])
    else
      @master_tree = MasterTree.find(params[:id])
      @master_tree.update_attributes(params[:master_tree])
      if @master_tree.save
        if request.xhr?
          render :json => { :status => "OK"}
        else
          flash[:success] = "Working Tree successfully updated"
          redirect_to master_tree_url(@master_tree.id)
        end
      else
        render :edit
      end
    end
  end

  def destroy
    @master_tree = MasterTree.find(params[:id])
    @deleted_tree = DeletedTree.find_by_master_tree_id(params[:id])
    if @master_tree.nuke && @deleted_tree.nuke
      flash[:notice] = 'Tree successfully deleted'
      redirect_to :action => :index
    end
  end

  def publish
    gp = GnaclrPublisher.create!(:master_tree_id => params[:id].to_i)
    Resque.enqueue(GnaclrPublisher, gp.id)
    render :json => { :status => "OK" }
  end
  
  def undo
    render :json => UndoActionCommand.undo(params[:id]).serializable_hash
  end
  
  def redo
    render :json => RedoActionCommand.redo(params[:id]).serializable_hash
  end

end
