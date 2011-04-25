class RedoActionCommand < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :action_command

  def self.redo_actions(master_tree_id)
    self.where(:master_tree_id => master_tree_id).order("id desc").limit(Gnite::Config.undo_limit)
  end

  def self.redo(master_tree_id)
    redo_actions = self.where(:master_tree_id => master_tree_id).order("id desc").limit(1)
    action = redo_actions.empty? ? nil : redo_actions[0].action_command
    ActionCommand.schedule_actions(action) if action
    action
  end
end
