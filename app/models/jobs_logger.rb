class JobsLogger
  attr_reader :subscriptions

  def initialize
    @subscriptions = {}
  end

  def info(message)
    an_object_id, message = message.split("|")[1..2]
    if an_object_id && @subscriptions[an_object_id.to_i]
      tree_id = @subscriptions[an_object_id.to_i][:tree_id]
      job_type = @subscriptions[an_object_id.to_i][:job_type]
      JobsLog.create(:tree_id => tree_id, :message => message, :job_type => job_type)
    end
  end

  def subscribe(opts)
    an_object_id = opts[:an_object_id]
    tree_id =  opts[:tree_id]
    job_type = opts[:job_type]
    @subscriptions[an_object_id] = { :tree_id => tree_id, :job_type => job_type }
  end

  def unsubscribe(an_object_id)
    @subscriptions.delete(an_object_id)
  end

end
