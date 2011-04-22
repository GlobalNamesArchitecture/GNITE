class BookmarksJsonPresenter
  def self.present(nodes)

    bookmark_hashes = nodes.map do |node|
      bookmarks_title = []
      treepath_ids = []
      
      node.ancestors.each do |ancestor|
        treepath_ids << "#" + ancestor.id.to_s
      end
      
      treepath_ids << "#" + node.id.to_s
      
      bookmark_hash = {
        :bookmark => {
          :id => node.bookmarks.first.id,
          :title => node.bookmarks.first.bookmark_title,
          :treepath => treepath_ids
        }
      }

    end

    bookmark_hashes.to_json
    
  end
end