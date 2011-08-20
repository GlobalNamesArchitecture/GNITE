class FamilyReunion
  class TopNode
    attr :data

    def initialize(data)
      @data = data
      @valid_names_hash = nil
      @valid_names_duplicates = nil
      @synonyms_hash = nil
      @ids_hash = nil
      @paths_hash = nil
    end

    def valid_names_hash
      return @valid_names_hash if @valid_names_hash #TODO: make it more robust for situations with exceptions etc.
      @valid_names_duplicates = {}
      @valid_names_hash = {}
      @paths_hash = {}
      @data[:leaves].each do |row|
        canonical = row[:valid_name][:canonical_name]
        update_paths_hash(row)
        if @valid_names_hash.has_key?(canonical)
          if @valid_names_duplicates.has_key?(canonical)
            @valid_names_duplicates[canonical] << row
          else
            @valid_names_duplicates[canonical] = [row]
          end
        else
          @valid_names_hash[canonical] = row
        end
      end
      @valid_names_duplicates.keys.each do |k|
        @valid_names_duplicates[k] << @valid_names_hash.delete(k)
      end
      data[:empty_nodes].each do |row|
        update_paths_hash(row)
      end
      @valid_names_hash
    end

    def paths_hash
      unless @paths_hash
        valid_names_hash
      end
      @paths_hash
    end

    def ids_hash
      return @ids_hash if @ids_hash
      @ids_hash = valid_names_hash.inject({}) do |res, key_val|
        res[key_val[1][:id].to_s.to_sym] = key_val[1]
        res
      end
      data[:empty_nodes].each do |node|
        @ids_hash[node[:id].to_s.to_sym] = node
      end
      @ids_hash
    end

    def synonyms_hash
      return @synonyms_hash if @synonyms_hash
      @synonyms_hash = {}
      @valid_names_hash.keys.each do |name|
        synonyms = @valid_names_hash[name][:synonyms]
        synonyms.each do |syn|
          @synonyms_hash.has_key?(syn[:canonical_name]) ? @synonyms_hash[syn[:canonical_name]] << @valid_names_hash[name] : @synonyms_hash[syn[:canonical_name]] = [@valid_names_hash[name]]
        end
      end
      @synonyms_hash
    end

    def valid_names_duplicates
      valid_names_hash unless @valid_names_duplicates
      @valid_names_duplicates
    end

    def update_paths_hash(node)
      path = node[:path].map { |n| n.to_sym }
      path_ids = node[:path_ids].map { |i| i.to_s.to_sym }
      until path.empty?
        populate_paths_hash(path, path_ids)
        path.pop
        path_ids.pop
      end
    end

    def populate_paths_hash(path, path_ids)
      name = path[-1]
      unless @paths_hash[name]
        @paths_hash[name] = [path.dup, path_ids.dup]
      end
    end

    def root_paths
      unless @root_name && @root_id
        @root_id = data[:leaves][0][:path_ids][0].to_s.to_sym
        @root_name = data[:leaves][0][:path][0]
      end
      [[@root_name], [@root_id]]
    end

  end
end
