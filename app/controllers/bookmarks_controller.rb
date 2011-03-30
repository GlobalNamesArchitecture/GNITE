class BookmarksController < ApplicationController
  before_filter :authenticate
  
  def index
    tree_id = params[:master_tree_id] || params[:reference_tree_id]

    if params[:master_tree_id]
      tree = current_user.master_trees.find(tree_id)
    else
      tree = current_user.reference_trees.find(tree_id)
    end

    nodes = tree.nodes.find(:all, :joins => :bookmarks, :order => 'bookmarks.created_at desc')
    render :json => TreeSearchJsonPresenter.present(nodes)
  end
  
  def create
    @bookmark = Bookmark.new(:node_id => params[:id])
    @bookmark.save
    respond_to do |format|
      format.json do
        render :json => @bookmark
      end
    end
  end
  
  def destroy
    @bookmark = Bookmark.find_by_node_id(params[:id])
    @bookmark.destroy
    respond_to do |format|
      format.json do
        render :json => { :status => "OK" }
      end
    end
  end
  
end