# class ActionMoveNodeToDeletedTree < ActionCommand
# 
#   def precondition_do
#     parent = Node.find(parent_id)
#     !!Node.find(node_id) && parent && ancestry_ok?(parent) 
#   end
# 
#   private
# 
#   def do_action
#     copy = node.deep_copy_to(master_tree.deleted_tree)
#     copy.parent_id = nill 
#     copy.save!
#     node.destroy_with_childrengt
#   end
# 
#   def undo_action
#     parent = Node.find(parent_id)
#     copy = deep_copy_to(parent.master_tree)
#     copy.parent_id = parent_id
#     copy.save!
#     destination_node_id.destroy_with_children
#   end
# 
# end
