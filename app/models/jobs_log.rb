class JobsLog < ActiveRecord::Base
  belongs_to :tree
  after_create :push_message

  private
  def push_message
    Juggernaut.publish("tree_#{tree.id}", "{\"message\" : \"#{message}\"}")
  end
end
