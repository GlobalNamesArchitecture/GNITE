class UndoActionCommand < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :action_command

  def self.undo_actions(master_tree_id)
    self.where(:master_tree_id => master_tree_id).order("id desc").limit(Gnite::Config.undo_limit)
  end

  def self.undo(undo_action_command)
    master_tree = undo_action_command.action_command.master_tree
    undo_actions = self.where("master_tree_id = ? and id >= ?", master_tree, undo_action_command.id).order("id desc")
    actions = undo_actions.map {|u| u.action_command}
    ActionCommand.schedule_actions(actions)
  end
end
