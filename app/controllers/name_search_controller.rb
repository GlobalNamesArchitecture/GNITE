class NameSearchController < ApplicationController
  before_filter :authenticate

  def show
    tree_id = params[:master_tree_id] || params[:reference_tree_id]

    if params[:master_tree_id]
      tree = current_user.master_trees.find(tree_id)
    else
      tree = current_user.reference_trees.find(tree_id)
    end

    node = tree.nodes.find(params[:id])

    render :json => {
      :rank             => node.rank_string,
      :synonyms         => node.synonym_name_strings,
      :vernacular_names => node.vernacular_name_strings
    }
  end

end