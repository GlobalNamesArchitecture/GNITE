class MergeEventsController < ApplicationController

  def index
    page = (params[:page]) ? params[:page] : 1
    @merge_events = MergeEvent.where(:master_tree_id => params[:master_tree_id])
                              .reverse
                              .paginate(:page => page, :per_page => 25)
    
    @master_tree = MasterTree.find(params[:master_tree_id])
    
  end

  def show
    @merge_event = MergeEvent.find(params[:id])
  end

  def create
    nodes = [params[:merge][:master_tree_node], params[:merge][:reference_tree_node]]
    nodes = nodes.reverse if params[:merge][:authoritative_node] == params[:merge][:reference_tree_node]
    master_tree = MasterTree.find(params[:master_tree_id])
    memo = "#{Node.find(params[:merge][:master_tree_node]).name_string}" \
           << " in " << "#{master_tree.title}" \
           << " merged with " << "#{Node.find(params[:merge][:reference_tree_node]).name_string}" \
           << " in " << "#{ReferenceTree.find(Node.find(params[:merge][:reference_tree_node]).tree_id).title}"
    @merge_event = MergeEvent.create!(
      :primary_node_id => nodes[0], 
      :secondary_node_id => nodes[1], 
      :master_tree => master_tree, 
      :user => current_user,
      :memo => memo,
      :status => 'merging')
    Resque.enqueue(MergeEvent, @merge_event.id)
    render :show
  end
end
