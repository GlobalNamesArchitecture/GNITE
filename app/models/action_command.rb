class ActionCommand < ActiveRecord::Base
  belongs_to :user
  @queue = Gnite::Config.action_queue 
  
  def self.perform(instance_id)
    ac = ActionCommand.find(instance_id)
    if ac.undo?
      if ac.precondition_undo
        ac.undo_action
        ac.undo = false
      else
        ac.precondition_undo_error
      end
    else
      if ac.precondition_do
        ac.do_action
        ac.undo = true
      else
        ac.precondition_do_error
      end
    end
    ac.save!
  end
  
  def precondition_do
    raise_not_implemented
  end
  
  def precondition_undo
    precondition_do
  end
    
  def raise_not_implemented
    raise "Implement Perform in your child class"
  end
  
  def undo_action
    raise_not_implemented
  end
  
  def do_action
    raise_not_implemented
  end
  
  def precondition_do_error
    raise Gnite::ActionPreconditionsError, "Preconditions are not met"
  end

  def precondition_undo_error
    precondition_do_error
  end
  
  def ancestry_ok?(a_node)
    a_node.ancestors.map {|a| a.tree_id}.uniq.size == 1
  end
  
end
