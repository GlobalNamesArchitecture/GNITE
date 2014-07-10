class TreeExpandController < ApplicationController
  before_filter :authenticate_user!

  def show
    tree = get_tree
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
     render json: result.uniq
  end

end
