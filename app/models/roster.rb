class Roster < ActiveRecord::Base

  belongs_to :user
  belongs_to :master_tree
  
  class << self
    
    def subscribe
      Juggernaut.subscribe do |event, data|

        master_tree_id = data["meta"] && data["meta"]["master_tree_id"]
        user_id = data["meta"] && data["meta"]["user_id"]
        next unless master_tree_id && user_id

        case event
          when :subscribe
            event_subscribe(master_tree_id, user_id)
          when :unsubscribe
            event_unsubscribe(user_id)
          end
        end
    end
    
    protected
    
      def event_subscribe(master_tree_id, user_id)
        master_tree_roster_user = find_by_master_tree_id_and_user_id(master_tree_id, user_id) || self.new(:master_tree_id => master_tree_id, :user_id => user_id)
        master_tree_roster_user.increment!
      end

      def event_unsubscribe(user_id)
        master_tree_roster_user = find_by_user_id(user_id) rescue nil
        master_tree_roster_user && master_tree_roster_user.decrement
      end
    
  end
  
  def increment!
    save!
  end
  
  def decrement
    destroy
  end
  
end