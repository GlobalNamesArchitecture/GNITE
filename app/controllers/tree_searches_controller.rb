class TreeSearchesController < ApplicationController
  before_filter :authenticate_user!

  def show
    @searched_term = params[:name_string]
    nodes = Node.search(@searched_term, params[:tree_id])
    
    @searches = nodes.map do |node|
      treepath_strings = []
      treepath_ids = []
      
      node.ancestors.each do |ancestor|
        treepath_strings << ancestor.name_string
        treepath_ids << "#" + ancestor.id.to_s
      end
      
      treepath_strings << node.name_string
      treepath_ids << "#" + node.id.to_s
      
      search = {
        name: node.name_string,
        id: node.id,
        treepath: {
          name_strings: treepath_strings.join(' &gt; '),
          node_ids: treepath_ids.join(',')
        }
      }

    end
    
    render partial: 'tree_search'
  end

end
