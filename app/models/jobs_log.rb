class JobsLog < ActiveRecord::Base
  belongs_to :tree
  after_create :push_message

  private
  def push_message
    Juggernaut.publish("tree_#{tree.id}", "{\"subject\" : \"#{self.job_type}\", \"message\" : \"#{message}\"}")
  end
end
