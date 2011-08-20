class FamilyReunion
  class FuzzyMatcher
    include MatcherHelper

    def initialize(family_reunion)
      @fr = family_reunion
      @tw = FamilyReunion::TaxamatchWrapper.new
    end

    def merge
      FamilyReunion.logger_write(@fr.object_id, "Merging fuzzy matches of accepted names")
      add_matches(get_valid_matches, :fuzzy_valid_to_valid)
      FamilyReunion.logger_write(@fr.object_id, "Merging fuzzy matches of accepted names to synonyms")
      add_matches(get_valid_to_synonym_matches, :fuzzy_valid_to_synonym)
      FamilyReunion.logger_write(@fr.object_id, "Merging fuzzy matches of synonyms to accepted names")
      add_matches(get_synonym_to_valid_matches, :fuzzy_synonym_to_valid)
      FamilyReunion.logger_write(@fr.object_id, "Merging fuzzy matches of synonyms")
      add_matches(get_synonym_to_synonym_matches, :fuzzy_synonym_to_synonym)
    end

    def get_valid_matches
      primary_names = @fr.primary_valid_names_set - @fr.secondary_valid_names_set
      secondary_names = @fr.secondary_valid_names_set - @fr.primary_valid_names_set
      make_match(primary_names, secondary_names, :valid_name, :valid_name)
    end

    def get_valid_to_synonym_matches
      primary_names = @fr.primary_valid_names_set - @fr.secondary_synonyms_set
      secondary_names = @fr.secondary_synonyms_set - @fr.primary_valid_names_set
      make_match(primary_names, secondary_names, :valid_name, :synonym)
    end

    def get_synonym_to_valid_matches
      primary_names = @fr.primary_synonyms_set - @fr.secondary_valid_names_set
      secondary_names = @fr.secondary_valid_names_set - @fr.primary_synonyms_set
      make_match(primary_names, secondary_names, :synonym, :valid_name)
    end

    def get_synonym_to_synonym_matches
      primary_names = @fr.primary_synonyms_set - @fr.secondary_synonyms_set
      secondary_names = @fr.secondary_synonyms_set - @fr.primary_synonyms_set
      make_match(primary_names, secondary_names, :synonym, :synonym)
    end

    private

    def add_matches(matched_nodes, merge_type)
      matched_nodes.each do |primary_node, secondary_nodes|
        primary_id = primary_node[:id].to_s.to_sym
        secondary_ids = secondary_nodes.map { |n| n[:id].to_s.to_sym }
        secondary_id_matches = format_secondary_id_for_merge(secondary_ids, merge_type)
        add_record_to_merges(primary_id, secondary_id_matches)
      end
    end


    def make_match(primary_names, secondary_names, primary_name_type, secondary_name_type)
      canonical_matches = @tw.match_canonicals_lists(primary_names, secondary_names)
      match_nodes_candidates = get_nodes_from_canonicals(canonical_matches, primary_name_type, secondary_name_type)
      @tw.match_nodes(match_nodes_candidates)
    end

    def get_nodes_from_canonicals(canonical_matches, primary_name_type, secondary_name_type)
      res = []
      canonical_matches.each do |primary_name, secondary_names|
        primary_nodes = self.send("get_#{primary_name_type}_node", @fr.primary_node, primary_name)
        secondary_nodes = secondary_names.map do |secondary_name|
          self.send("get_#{secondary_name_type}_node", @fr.secondary_node, secondary_name)
        end
        append_nodes(res, primary_nodes, secondary_nodes)
      end
      res
    end

    def append_nodes(nodes, primary_nodes, secondary_nodes)
      secondary_nodes = secondary_nodes.flatten.uniq
      primary_nodes.each do |primary_node|
        nodes << [primary_node, secondary_nodes]
      end
    end

    def get_valid_name_node(top_node, name)
      node = top_node.valid_names_hash[name]
      node.merge!({ :name_to_match => node[:valid_name][:name] })
      [node]
    end

    def get_synonym_node(top_node, name)
      nodes = top_node.synonyms_hash[name]
      nodes.each do |n|
        synonym_name = n[:synonyms].select { |s| s[:canonical_name] == name }.first[:name]
        n.merge!({ :name_to_match => synonym_name })
      end
    end

  end
end
