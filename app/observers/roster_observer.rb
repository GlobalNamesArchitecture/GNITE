class RosterObserver < ActiveRecord::Observer
  observe :roster
    
  def after_create(rec)
    publish(:create, rec)
  end
  
  def after_destroy(rec)
    publish(:destroy, rec)
  end
  
  protected
    def publish(type, rec)
      count = Roster.count(:conditions => "master_tree_id = #{rec.master_tree_id}")
      total_count = Roster.count
      user = User.find(rec.user_id)
      Juggernaut.publish("tree_#{rec.master_tree_id}", {
        :subject => "roster",
        :message => "",
        :user => { :id => user.id, :email => user.email },
        :status => type,
        :count => count-1,
        :time => Time.new.to_s
      }.to_json)
      Juggernaut.publish("admin_roster", {
        :user => { :id => user.id, :email => user.email },
        :master_tree_id => rec.master_tree_id,
        :status => type,
        :count => total_count
      }.to_json)
    end
end