class MergeResultPrimary < ActiveRecord::Base
  belongs_to :merge_event
  belongs_to :node
  has_many :merge_result_secondaries

  def self.import_merge(merge_event)
    merge_event.merge.each do |key, value|
      key = key.to_s.to_i
      path = value[:path]
      merge_result_primary = self.create!(:merge_event => merge_event, :id => key, :path => path)
      require 'ruby-debug'; debugger
      add_merge_result(merge_result_primary, value[:matches])
      add_merge_result(merge_result_primary, value[:nonmatches])
    end
    
  end

  private

  def self.add_merge_result(merge_result_primary, merges)
    merges.each do |node_id, value|
      node_id = node_id.to_s.to_i
      path = value[:path]
      merge_type, merge_subtype = find_merge_types(value[:merge_type])
      MergeResultSecondary.create!(:merge_result_primary => merge_result_primary, 
                                   :node_id => node_id, 
                                   :path => path,
                                   :merge_type => merge_type,
                                   :merge_subtype => merge_subtype)
      
    end
  end

  def self.find_merge_types(merge_type_string)
    res = merge_type_string.split("_", 2)
    merge_type = MatchType.find_by_label(res[0])
    merge_sub_type = res[1] ? MatchSubtype.find_by_label(res[1].gsub("_", " ")) : nil
    [merge_type, merge_subtype]
  end    

end
