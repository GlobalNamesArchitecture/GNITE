class MergeDecision < ActiveRecord::Base
  has_many :merge_result_secondaries

  def self.accepted
    @accepted ||= self.find_by_label("accepted")
  end

  def self.rejected
    @rejected ||= self.find_by_label("rejected")
  end

  def self.postponed
    @postponed ||= self.find_by_label("postponed")
  end

end
