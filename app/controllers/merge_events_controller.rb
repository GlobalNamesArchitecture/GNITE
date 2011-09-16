class MergeEventsController < ApplicationController
  before_filter :authenticate_user!

  def index
    page = (params[:page]) ? params[:page] : 1
    @merge_events = MergeEvent.includes(:user)
                              .where(:master_tree_id => params[:master_tree_id])
                              .paginate(:page => page, :per_page => 25)
                              .reverse
    
    @master_tree = MasterTree.find(params[:master_tree_id])
    
  end

  def show
    @merge_event = MergeEvent.find(params[:id])
    @master_tree = @merge_event.master_tree

    @master_tree.rosters.delete_if { |h| h.user_id == current_user.id }
    @master_tree.master_tree_contributors.delete_if { |h| h.user_id == current_user.id }
    
    editors = []
    @master_tree.rosters.each do |roster|
      editors << { :id => roster.user.id, :email => roster.user.email, :roles => roster.user.roles.map { |r| r.name.humanize }, :status => "online" }
    end
    @master_tree.master_tree_contributors.each do |contributor|
      editors << { :id => contributor.user.id, :email => contributor.user.email, :roles => contributor.user.roles.map { |r| r.name.humanize }, :status => "offline" } unless editors.any? { |h| h[:id] == contributor.user.id }
    end
    
    @editors = editors.sort_by { |h| h[:email] }
    
    if @merge_event.status != "in review"
      redirect_to master_tree_path(@master_tree)
    end

    reference_tree = ReferenceTree.find(Node.find(@merge_event.secondary_node_id).tree_id) rescue nil
    @reference_tree = !reference_tree.nil? ? reference_tree : ReferenceTree.find(Node.find(@merge_event.primary_node_id).tree_id)
    @decision_types = MergeDecision.all

    type_to_label ||= MergeType.all.each_with_object({}){ |type,key| key[type.id] = type.label }
    subtype_to_label ||= MergeSubtype.all.each_with_object({}){ |subtype,key| key[subtype.id] = subtype.label.gsub(/ /,'-') }
    
    @data = { new_matches: [], exact_matches: [], fuzzy_matches: [] }
    @busy = false

    results = MergeResultPrimary.includes(:merge_result_secondaries).where(:merge_event_id => params[:id])
    results.each do |primary|      
      primary.merge_result_secondaries.each do |secondary|
        type = type_to_label[secondary.merge_type_id]
        @data["#{type}_matches".to_sym] << {
            :id             => secondary.id,
            :primary_path   => primary.path,
            :secondary_path => secondary.path,
            :type           => type,
            :subtype        => subtype_to_label[secondary.merge_subtype_id],
            :merge_decision => secondary.merge_decision_id
        }
        if secondary.merge_decision_id == nil || secondary.merge_decision_id == 3
          @busy = true
        end
      end
    end
    
    @data.delete_if { |k, v| v.empty? }
    
    last_log = JobsLog.where(:tree_id => @master_tree, :job_type => 'MergeEvent').last unless @merge_event.status == "in review" 
    
    @merge_last_log = (!last_log.nil?) ? last_log.message : ""

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

    respond_to do |format|
      format.json do
        render :json => { :status => "OK", :merge_event => @merge_event.id }
      end
    end
  end
  
  def update
    params[:data].each do |decision|
      decision_item = MergeResultSecondary.find(decision[:merge_result_secondary_id])
      decision_item.update_attributes(:merge_decision_id => decision[:merge_decision_id])
      decision_item.save
    end
    respond_to do |format|
      format.json do
        render :json => { :status => "OK" }
      end
    end
  end

  def do
    me = MergeEvent.find(params[:id])
    
    if params[:discard]
      me.master_tree.state = 'active'
      me.master_tree.save!
      channel = "tree_#{me.master_tree.id}"
      Juggernaut.publish(channel, { :subject => "unlock" }.to_json)
      me.status = "discarded"      
    else
      master_tree_node = me.primary_node.tree == me.master_tree ? me.primary_node : me.secondary_node
      parent = master_tree_node.parent
      params[:action_type] = "ActionMoveNodeToDeletedTree"
      schedule_action(master_tree_node, me.master_tree, params)
      merge_tree_node = me.merge_tree.root.children[0]
      params[:node] = {}
      params[:node][:parent_id] = parent.id
      params[:action_type] = "ActionCopyNodeFromAnotherTree"
      schedule_action(merge_tree_node, me.master_tree, params)
      me.status = "complete"
    end

    me.save!
    redirect_to master_tree_path(me.master_tree)

  end
  
end
