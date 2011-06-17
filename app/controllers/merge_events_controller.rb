class MergeEventsController < ApplicationController

  def show
    @merge_event = MergeEvent.find(params[:merge_event_id])
  end

  def create
    nodes = [params[:merge][:master_tree_node], params[:merge][:reference_tree_node]]
    nodes = nodes.reverse if params[:merge][:authoritative_node] == params[:merge][:master_tree_node]
    master_tree = MasterTree.find(params[:master_tree_id])
    @merge_event = MergeEvent.create!(
      :primary_node_id => nodes[0], 
      :secondary_node_id => nodes[1], 
      :master_tree => master_tree, 
      :user => current_user,
      :status => 'merging')
    Resque.enqueue(MergeEvent, @merge_event.id)
    render :show
  end
end
