class ActionChangeRank < ActionCommand

  def precondition_do
    @json_do = JSON.parse(json_message, :symbolize_names => true)[:do]
    !!(node && @json_do)
  end

  def precondition_undo
    @json_undo = JSON.parse(json_message, :symbolize_names => true)[:undo]
    !!(@json_undo)
  end

  def do_action
    self.json_message = {:do => @json_do, :undo => node.rank}.to_json
    save!
    node.rank = @json_do
    node.save!
  end

  def undo_action
    node.rank = JSON.parse(json_message, :symbolize_names => true)[:undo]
    node.save!
  end
  
  def do_log
    rank = JSON.parse(json_message, :symbolize_names => true)[:do]
    "#{old_name} given rank #{rank}"
  end
  
  def undo_log
    rank = JSON.parse(json_message, :symbolize_names => true)[:undo]
    "#{old_name} reverted to rank #{rank}"
  end

end