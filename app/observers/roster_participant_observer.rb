class RosterParticipantObserver < ActiveRecord::Observer
  observe :roster_participant
    
  def after_create(rec)
    publish(:create, rec)
  end
  
  def after_destroy(rec)
    publish(:destroy, rec)
  end
  
  protected
    def publish(type, rec)
      master_tree_roster = Roster.find(rec.roster_id) rescue nil
      user = User.find(rec.user_id) rescue nil
      count = master_tree_roster.roster_participants.count - 1
      Juggernaut.publish("tree_#{master_tree_roster.master_tree_id}", {
        :subject => "roster",
        :message => "",
        :user => { :id => user.id, :email => user.email },
        :status => type,
        :count => count,
        :time => Time.new.to_s
      }.to_json)
    end
end