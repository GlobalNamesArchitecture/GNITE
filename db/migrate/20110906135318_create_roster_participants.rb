class CreateRosterParticipants < ActiveRecord::Migration
  def self.up
    create_table :roster_participants do |t|
      t.references :roster, :user
    end
  end

  def self.down
    drop_table :roster_participants
  end
end
