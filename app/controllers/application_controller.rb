class ApplicationController < ActionController::Base
  include Clearance::Authentication
  protect_from_forgery
  layout 'application'

  def authenticate
    deny_access("You must sign in to view that page") unless signed_in?
  end

  private

  def get_tree
    tree_id = params[:master_tree_id] || params[:reference_tree_id] || params[:deleted_tree_id] || params[:merge_tree_id]

    if params[:master_tree_id]
      tree = current_user.master_trees.find(tree_id)
    elsif params[:reference_tree_id]
      tree = ReferenceTree.find(tree_id)
    elsif params[:deleted_tree_id]
      tree = DeletedTree.find(tree_id)
    elsif params[:merge_tree_id]
      tree = MergeTree.find(tree_id)
    else
      tree = nil unless tree.master_tree.users.find(current_user)
    end
    tree
  end

end
