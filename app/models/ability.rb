class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    if user.has_role? :admin
      can :manage, :all
    else
      can :index, MasterTree, :master_tree_contributors => { :user_id => user.id }
      can :show, MasterTree do |master_tree|
        master_tree.users.include?(user) || master_tree.user_id == user.id
      end
      can :new, MasterTree
      can [:edit, :update, :publish, :destroy], MasterTree, :user_id => user.id
    end
  end
end
