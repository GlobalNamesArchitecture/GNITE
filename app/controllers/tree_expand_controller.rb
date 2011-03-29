class TreeExpandController < ApplicationController
  before_filter :authenticate

  def show
    tree_id = params[:master_tree_id] || params[:reference_tree_id] || params[:deleted_tree_id]
    if params[:master_tree_id]
      tree = current_user.master_trees.find(tree_id)
    elsif params[:reference_tree_id]
      tree = current_user.reference_trees.find(tree_id)
    else
      tree = current_user.deleted_trees.find(tree_id)
    end
    
    names = Node.search(params[:search_string].downcase, tree_id)
    result = []
    names.each do |name|
      nodes = tree.nodes.find_all_by_name_id(name.id)
      nodes.each do |node|
        node.ancestors.each do |parent|
          result << "#" + parent.id.to_s
        end
      end
    end
     render :json => result.uniq
  end

end
