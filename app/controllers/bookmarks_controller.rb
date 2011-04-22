class BookmarksController < ApplicationController
  before_filter :authenticate

  def index
    tree = get_tree
    nodes = tree.nodes.find(:all, :include => :bookmarks, :joins => :bookmarks, :order => 'bookmarks.created_at desc')
    render :json => nodes.length > 0 ? BookmarksJsonPresenter.present(nodes) : { :status => "No bookmarks found" }
  end

  def create
    @bookmark = Bookmark.new(:node_id => params[:id], :bookmark_title => params[:bookmark_title])
    @bookmark.save
    respond_to do |format|
      format.json do
        render :json => @bookmark
      end
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    respond_to do |format|
      format.json do
        render :json => { :status => "OK" }
      end
    end
  end

end
