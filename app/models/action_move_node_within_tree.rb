# class ActionMoveNodeWithinTree < ActionCommand
#   
#   def precondition_do
#     parent = Node.find(parent_id)
#     destination = Node.find(destination_node_id)
#     !!Node.find(node_id) && parent && destination && ancestry_ok?(parent) && ancestry_ok?(destination) && parent.tree_id == destination.tree_id
#   end
#   
#   private
#   
#   def do_action
#     Node.parent_id = destination_node_id
#     Node.save!
#   end
#   
#   def undo_action
#     Node.parent_id = parent_id
#     Node.save!
#   end
#   
# end
