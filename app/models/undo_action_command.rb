class UndoActionCommand < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :action_command

  def self.undo_actions(master_tree_id)
    self.where(:master_tree_id => master_tree_id).order("id desc").limit(Gnite::Config.undo_limit)
  end

  def self.undo(master_tree_id, session_id)
    undo_actions = self.where(:master_tree_id => master_tree_id).order("id desc").limit(1)
    action = undo_actions.empty? ? nil : undo_actions[0].action_command
    ActionCommand.schedule_actions(action, session_id) if action
    action
  end
end
