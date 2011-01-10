# class ActionCopyNodeFromAnotherTree < ActionCommand
# 
#   def precondition_do
#     destination_parent = Node.find(destination_parent_id)
#     !!Node.find(node_id) && !!destination_parent && ancestry_ok?(destination_parent)
#   end
# 
#   def precondition_undo
#     destination_node = destination_parent_id ? Node.find(destination_parent_id) : nil
#     !!destination_node
#   end
# 
#   private
# 
#   def do_action
#     destination_parent = Node.find(destination_parent_id)
#     copy = node.deep_copy_to(destination_parent.tree)
#     copy.parent_id = destination_parent_id
#     copy.save!
#   end
# 
#   def undo_action
#     destination_node_id.destroy_with_children
#   end
# end
