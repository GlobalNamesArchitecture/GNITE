class BookmarksController < ApplicationController
  before_filter :authenticate

  def index
    tree = get_tree
    nodes = tree.nodes.find(:all, :joins => :bookmarks, :order => 'bookmarks.created_at desc')
    render :json => nodes.length > 0 ? TreeSearchJsonPresenter.present(nodes) : { :status => "No bookmarks found" }
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
