class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :master_editor
      can :manage, [MasterTree, Node, Synonym, VernacularName]
    else
      can :new, MasterTree
      can :index, MasterTree, :master_tree_contributors => { :user_id => user.id }
      can [:edit, :update, :publish, :destroy], MasterTree, :user_id => user.id
      can [:show, :undo, :redo], MasterTree do |master_tree|
        master_tree.users.include?(user) || master_tree.user_id == user.id
      end
      can [:index, :show], Node
      # :create needs an instance so is handled through controller
      can [:update], Node do |node|
        node.parent.tree.users.include?(user) || node.parent.tree.user_id == user.id
      end
      # :create needs an instance so is handled through controllers
      can [:update, :destroy], [Synonym, VernacularName] do |obj|
        obj.node.tree.users.include?(user) || obj.node.tree.user_id == user.id
      end
    end
  end
end
