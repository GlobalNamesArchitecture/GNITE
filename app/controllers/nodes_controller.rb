class NodesController < ApplicationController
  before_filter :authenticate

  def index
    respond_to do |format|
      format.json do
        tree_id = params[:master_tree_id] || params[:reference_tree_id] || params[:deleted_tree_id]
        if params[:master_tree_id]
          tree = current_user.master_trees.find(tree_id)
        elsif params[:reference_tree_id]
          tree = current_user.reference_trees.find(tree_id)
        else
          tree = current_user.deleted_tree.find(tree_id)
        end
        nodes = tree.children_of(params[:parent_id])
        render :json => NodeJsonPresenter.present(nodes)
      end
    end
  end

  def show
    tree_id = params[:master_tree_id] || params[:reference_tree_id] || params[:deleted_tree_id]

    if params[:master_tree_id]
      tree = current_user.master_trees.find(tree_id)
    elsif params[:reference_tree_id]
      tree = current_user.reference_trees.find(tree_id)
    else
      tree = current_user.deleted_tree.find(tree_id)
    end

    node = tree.nodes.find(params[:id])

    render :json => {
      :rank             => node.rank_string,
      :synonyms         => node.synonym_name_strings,
      :vernacular_names => node.vernacular_name_strings
    }
  end

  def create
    respond_to do |format|
      format.json do
        name_attributes = params[:node].delete(:name)
        name            = Name.find_or_create_by_name_string(name_attributes[:name_string])
        node_attributes = params[:node].merge(:tree_id => params[:master_tree_id], :name => name)
        node            = Node.new(node_attributes)
        node.save
        render :json => node
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        master_tree = current_user.master_trees.find(params[:master_tree_id])
        node        = master_tree.nodes.find(params[:id])
        node.update_attributes(params[:node])
        render :json => node
      end
    end
  end

  def destroy
    # deleted_tree    = current_user.deleted_tree.find_by_master_tree_id(params[:master_tree_id])
    # master_tree     = current_user.master_trees.find(params[:master_tree_id])
    # root_node       = master_tree.nodes.find(params[:id])
    # 
    # root_node.update_attributes(:parent_id => nil, :tree_id => deleted_tree.id)
    #     
    # root_node.descendants.each do |descendant|
    #   node = master_tree.nodes.find_by_id(descendant.id)
    #   node.update_attributes(:tree_id => deleted_tree.id)
    # end
    #     
    # head :ok
    respond_to do |format|
      format.json do
       Node.destroy(params[:id])
       head :ok
      end
    end
  end

end
