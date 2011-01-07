class NameSearchesController < ApplicationController
  before_filter :authenticate

  def show
    tree_id = params[:master_tree_id] || params[:reference_tree_id] || params[:deleted_tree_id]
    if params[:master_tree_id]
      tree = current_user.master_trees.find(tree_id)
    elsif params[:reference_tree_id]
      tree = current_user.reference_trees.find(tree_id)
    else
      tree = current_user.deleted_tree.find(tree_id)
    end
    
    ancestors = []
    
    results = Node.search(params[:search_string].downcase, tree_id)
    results.each do |result|
      node = tree.nodes.find_by_name_id(result.id)
      node.ancestors.each do |parent|
        ancestors << "#" + parent.id.to_s
      end
    end
    render :json => ancestors
  end

end