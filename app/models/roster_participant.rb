class RosterParticipant < ActiveRecord::Base
  
  belongs_to :roster
  has_many :users

end