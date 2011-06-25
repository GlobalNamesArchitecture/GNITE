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
    @master_tree = @merge_event.master_tree
    reference_tree = ReferenceTree.find(Node.find(@merge_event.secondary_node_id).tree_id)
    @reference_tree = !reference_tree.blank? ? reference_tree : ReferenceTree.find(Node.find(@merge_event.primary_node_id).tree_id) 
    
    @merges = @merge_event.merge_result_primaries.map do |primary|
      reference_paths = []
      merge_types = []
      merge_subtypes = []
      
      primary.merge_result_secondaries.each do |secondary|
        reference_paths << secondary.path
        merge_types     << secondary.merge_type.label
        merge_subtypes  << secondary.merge_subtype.label unless secondary.merge_subtype.nil?
      end
      
      merge = { :id             => primary.id,
                :primary_path   => primary.path,
                :secondary_path => reference_paths.first,
                :type           => merge_types.first,
                :subtype        => merge_subtypes.first 
      }
      
    end
    
  end

  def create
    nodes = [params[:merge][:master_tree_node], params[:merge][:reference_tree_node]]
    nodes = nodes.reverse if params[:merge][:authoritative_node] == params[:merge][:reference_tree_node]
    master_tree = MasterTree.find(params[:master_tree_id])
    memo = "#{Node.find(params[:merge][:master_tree_node]).name_string}" \
           << " merged with " << "#{Node.find(params[:merge][:reference_tree_node]).name_string}" \
           << " in " << "#{ReferenceTree.find(Node.find(params[:merge][:reference_tree_node]).tree_id).title}"
    @merge_event = MergeEvent.create!(
      :primary_node_id => nodes[0], 
      :secondary_node_id => nodes[1], 
      :master_tree => master_tree, 
      :user => current_user,
      :memo => memo,
      :status => 'computing')
    Resque.enqueue(MergeEvent, @merge_event.id)
    redirect_to master_tree_merge_event_url(params[:master_tree_id], @merge_event.id)
  end
end
