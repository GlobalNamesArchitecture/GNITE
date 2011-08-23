class BookmarksController < ApplicationController
  before_filter :authenticate_user!

  def index
    tree = get_tree
    nodes = tree.nodes.find(:all, :include => :bookmarks, :joins => :bookmarks, :order => 'bookmarks.created_at desc')

    @bookmarks = nodes.map do |node|
      treepath_ids = []
      node.ancestors.each do |ancestor|
        treepath_ids << "#" + ancestor.id.to_s
      end
      treepath_ids << "#" + node.id.to_s
          
      bookmark = { :id => node.bookmarks.first.id, 
                   :title => node.bookmarks.first.bookmark_title, 
                   :tree_path => treepath_ids.join(",") }
    end
    
    render :partial => 'bookmark'
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
  
  def update
    @bookmark = Bookmark.find(params[:id])
    @bookmark.update_attributes(:bookmark_title => params[:bookmark_title])
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
