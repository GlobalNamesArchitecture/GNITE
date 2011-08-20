class FamilyReunion
  module MatcherHelper
    private
    def format_secondary_id_for_merge(secondary_ids, merge_type)
      secondary_ids.inject({}) do |res, i|
        raise "Secondary id is not a symbol" unless i.is_a?(Symbol)
        path = @fr.secondary_node.ids_hash[i][:path]
        path_ids = @fr.secondary_node.ids_hash[i][:path_ids]
        res[i] = { :merge_type => merge_type, :path => path, :path_ids => path_ids } unless res.has_key?(i)
        res
      end
    end

    def add_record_to_merges(primary_id, secondary_id_matches)
      raise "Primary id is not a symbol" unless primary_id.is_a?(Symbol)
      if @fr.merges.has_key?(primary_id)
        secondary_id_matches.each do |key, val|
          @fr.merges[primary_id][:matches][key] = val unless @fr.merges[primary_id][:matches].has_key?(key)
        end
      else
        path = @fr.primary_node.ids_hash[primary_id][:path]
        path_ids = @fr.primary_node.ids_hash[primary_id][:path_ids]     
        @fr.merges[primary_id] = { :path => path, :path_ids => path_ids, :matches => secondary_id_matches, :nonmatches => {} }
      end
    end
  end
end
