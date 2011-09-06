class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmed, :remember_me, :given_name, :surname, :affiliation

  belongs_to :roster_participant
  has_many :action_commands
  has_many :master_trees
  has_many :master_tree_contributors
  has_many :master_tree_logs
  has_many :merge_events
  
  has_and_belongs_to_many :roles
  
  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

end
