class Roster < ActiveRecord::Base

  belongs_to :master_tree
  has_many :roster_participants
  
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
            event_unsubscribe(master_tree_id, user_id)
          end
        end
    end
    
    protected
    
      def event_subscribe(master_tree_id, user_id)
        master_tree_roster = find_by_master_tree_id(master_tree_id) || self.create(:master_tree_id => master_tree_id)
        master_tree_roster.roster_participants.create(:user_id => user_id)
      end

      def event_unsubscribe(master_tree_id, user_id)
        master_tree_roster = find_by_master_tree_id(master_tree_id) rescue nil
        master_tree_roster && master_tree_roster.decrement(user_id)
      end
    
  end
  
  def decrement(user_id)
    participant = self.roster_participants.find_by_user_id(user_id) rescue nil
    participant && participant.destroy
    self.roster_participants.count > 0 ? save! : destroy
  end
  
end