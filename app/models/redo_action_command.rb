class RedoActionCommand < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :action_command
end
