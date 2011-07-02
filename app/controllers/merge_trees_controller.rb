class MergeTreesController < ApplicationController
  before_filter :authenticate

  def populate
    merge_tree = MergeTree.find(params[:id])
    merge_tree.root.children.each do |child|
      child.destroy_with_children
    end
    merge_tree.populate
    render :json => { :status => "OK" }
#    redirect_to :show
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
