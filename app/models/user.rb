class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_many :action_commands
  has_many :master_trees
  has_many :master_tree_contributors
  has_many :master_tree_logs
  has_many :merge_events
  has_one :roster
  has_and_belongs_to_many :roles

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end
  
  def update_with_password(params={})
    params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = update_attributes(params)
    clean_up_passwords
    result
  end
  
  def online?
    roster.present?
  end
  
  def active_master_tree
    roster.master_tree_id rescue nil
  end

end
