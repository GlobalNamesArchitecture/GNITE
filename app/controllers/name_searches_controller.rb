class NameSearchesController < ApplicationController
  before_filter :authenticate

  def show
    tree_id = params[:master_tree_id] || params[:reference_tree_id]

    if params[:master_tree_id]
      tree = current_user.master_trees.find(tree_id)
    else
      tree = current_user.reference_trees.find(tree_id)
    end

#    query = params[:search_string]

    node = tree.nodes.find_by_name_id(params[:search_string])

    render :json => {
      :results             => node.rank_string,
    }
  end

end