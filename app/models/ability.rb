class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    if user.has_role? :admin
      can :manage, :all
    else
      can :index, MasterTree, :master_tree_contributors => { :user_id => user.id }
      can :new, MasterTree
      can [:edit, :update, :publish, :destroy], MasterTree, :user_id => user.id
      can [:show, :undo, :redo], MasterTree do |master_tree|
        master_tree.users.include?(user)
      end
      can [:index, :show, :create, :update], Node do |node|
        node.tree.type == "MasterTree" && node.tree.users.include?(user)
      end
      can [:create, :update, :destroy], Synonym do |synonym|
        synonym.node.tree.type == "MasterTree" && synonym.node.tree.users.include?(user)
      end
      can [:create, :update, :destroy], VernacularName do |vernacular_name|
        vernacular_name.node.tree.type == "MasterTree" && vernacular_name.node.tree.users.include?(user)
      end
    end
  end
end
