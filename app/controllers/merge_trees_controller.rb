class MergeTreesController < ApplicationController
  before_filter :authenticate_user!

  def populate
    merge_tree = MergeTree.find(params[:id])
    merge_tree.nuke_nodes
    merge_tree.populate
    render :json => { :status => "OK" }
  end

  def show
    @merge_tree = MergeTree.find(params[:id])
    tree_data = flatten_tree
  end

  private

  def flatten_tree
    indent = 0
    res = []
    node = @merge_tree.root.children[0]
    res << node.name_string
    flatten_recursive(node, indent)
  end

  def flatten_recursive(node, indent)
    indent += 2
    node
  end
end
