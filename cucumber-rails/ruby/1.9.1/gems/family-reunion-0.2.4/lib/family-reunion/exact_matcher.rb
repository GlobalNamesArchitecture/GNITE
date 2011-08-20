class FamilyReunion
  class ExactMatcher
    include MatcherHelper

    def initialize(family_reunion)
      @fr = family_reunion
    end

    def merge
      FamilyReunion.logger_write(@fr.object_id, "Merging exact matches of accepted names")
      add_valid_matches(get_valid_matches)
      FamilyReunion.logger_write(@fr.object_id, "Merging exact matches of accepted names to synonyms")
      add_synonym_matches(get_valid_to_synonym_matches, :exact_valid_to_synonym)
      FamilyReunion.logger_write(@fr.object_id, "Merging exact matches of synonyms to accepted names")
      add_synonym_matches(get_synonym_to_valid_matches, :exact_synonym_to_valid)
      FamilyReunion.logger_write(@fr.object_id, "Merging exact matches of synonyms")
      add_synonym_matches(get_synonym_to_synonym_matches, :exact_synonym_to_synonym)
    end

    private

    def get_valid_matches
      valid_matches = @fr.primary_valid_names_set & @fr.secondary_valid_names_set
    end

    def add_valid_matches(valid_matches)
      # Homonyms are treated separately, and are not matched by the algorithm,
      # they are excluded from valid_matches
      valid_matches.each do |name|
        pn = @fr.primary_node.valid_names_hash[name]
        sn = @fr.secondary_node.valid_names_hash[name]
        primary_id = pn[:id].to_s.to_sym
        primary_path = pn[:path]
        primary_path_ids = pn[:path_ids]
        secondary_id = sn[:id].to_s.to_sym
        secondary_path = sn[:path]
        secondary_path_ids = sn[:path_ids]
        @fr.merges[primary_id] = { 
          :path => primary_path, 
          :path_ids => primary_path_ids, 
          :matches => {secondary_id => {
            :merge_type => :exact_valid_to_valid, 
            :path => secondary_path, 
            :path_ids => secondary_path_ids}}, 
          :nonmatches => {}
        }
      end
    end

    def get_valid_to_synonym_matches
      @fr.primary_valid_names_set & @fr.secondary_synonyms_set
    end

    def get_synonym_to_valid_matches
      @fr.primary_synonyms_set & @fr.secondary_valid_names_set
    end

    def get_synonym_to_synonym_matches
      @fr.primary_synonyms_set & @fr.secondary_synonyms_set
    end

    def add_synonym_matches(match_set, merge_type)
      match_set.each do |name|
        primary_ids, secondary_ids = get_valid_name_ids(name)
        secondary_id_matches = format_secondary_id_for_merge(secondary_ids, merge_type)
        primary_ids.each do |primary_id|
          add_record_to_merges(primary_id, secondary_id_matches)
        end
      end
    end

    def get_valid_name_ids(name)
      primary_ids = get_ids_from_node(name, @fr.primary_node)
      secondary_ids = get_ids_from_node(name, @fr.secondary_node)
      [primary_ids, secondary_ids]
    end

    def get_ids_from_node(name, node)
      valid_names = node.valid_names_hash
      synonyms = node.synonyms_hash
      if valid_names.has_key?(name)
        return [valid_names[name][:id].to_s.to_sym]
      else
        return synonyms[name].map {|n| n[:id].to_s.to_sym}
      end
    end

  end
end

