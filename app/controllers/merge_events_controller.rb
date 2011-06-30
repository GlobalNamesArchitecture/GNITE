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

    type_to_label ||= MergeType.all.each_with_object({}){ |type,key| key[type.id] = type.label }
    subtype_to_label ||= MergeSubtype.all.each_with_object({}){ |subtype,key| key[subtype.id] = subtype.label.gsub(/ /,'-') }
    
    results = MergeResultPrimary.includes(:merge_result_secondaries).where(:merge_event_id => params[:id])
    @exact_matches = []
    @fuzzy_matches = []
    @new_names = []
    results.each do |primary|      
      primary.merge_result_secondaries.each do |secondary|
        type = type_to_label[secondary.merge_type_id]
        if type == "exact"
          @exact_matches << {
            :id             => secondary.id,
            :primary_path   => primary.path,
            :secondary_path => secondary.path,
            :type           => type_to_label[secondary.merge_type_id],
            :subtype        => subtype_to_label[secondary.merge_subtype_id] 
          }
        elsif type == "fuzzy"
          @fuzzy_matches << {
            :id             => secondary.id,
            :primary_path   => primary.path,
            :secondary_path => secondary.path,
            :type           => type_to_label[secondary.merge_type_id],
            :subtype        => subtype_to_label[secondary.merge_subtype_id] 
          }
        else
          @new_names << {
            :id             => secondary.id,
            :secondary_path => secondary.path,
            :type           => type_to_label[secondary.merge_type_id]
          }
        end
      end
    end
    
    @exact_matches.sort! { |a,b| a[:primary_path] <=> b[:primary_path] }
    @fuzzy_matches.sort! { |a,b| a[:primary_path] <=> b[:primary_path] }
    @new_names.sort! { |a,b| a[:secondary_path] <=> b[:secondary_path] }
    
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
