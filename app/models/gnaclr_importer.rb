class GnaclrImporter
  attr_reader   :darwin_core_data, :name_strings, :tree
  attr_accessor :reference_tree_id, :url

  def initialize(opts)
    @reference_tree_id = opts[:reference_tree_id].to_i
    @url               = opts[:url]
    enqueue
  end

  def fetch_tarball
    Kernel.system("curl -s #{url} > #{tarball_path}")
  end

  def read_tarball
    dwc               = DarwinCore.new(tarball_path)
    normalizer        = DarwinCore::ClassificationNormalizer.new(dwc)
    @darwin_core_data = normalizer.normalize
    @tree             = normalizer.tree
    @name_strings     = normalizer.name_strings
  end

  def store_tree
    names = {}
    cache = {}

    puts "\n\n"

    Benchmark.bm do |x|
      x.report('Names') do
        name_strings.each do |name_string|
          name_id = Name.connection.select_value('SELECT id FROM names WHERE ' + Name.__send__(:sanitize_sql_for_conditions, :name_string => name_string))

          if name_id.nil?
            name_id = Name.connection.insert("INSERT INTO names (name_string) VALUES (" + Name.__send__(:quote_bound_value, name_string) + ")")
          end

          names[name_string] = name_id
        end
      end
    end

    Benchmark.bm do |x|
      x.report('Nodes') do
        build_tree(tree, names, cache)
      end
    end

    puts "\n\n"
  end

  def build_tree(root, names, cache)
    taxon_ids = root.keys
    taxon_ids.each do |taxon_id|
      name_id   = names[darwin_core_data[taxon_id].current_name]
      parent_id = cache[darwin_core_data[taxon_id].parent_id] if darwin_core_data[taxon_id].parent_id

      node = Node.create!(:name_id => name_id, :tree_id => reference_tree_id, :parent_id => parent_id)

      cache[taxon_id] = node.id

      build_tree(root[taxon_id], names, cache)

      cache.delete(taxon_id)
    end
  end

  def activate_tree
    ReferenceTree.update_all 'state = "active"', "id = #{reference_tree_id}"
  end

  def perform
    fetch_tarball
    read_tarball
    store_tree
    activate_tree
  end

  def enqueue
    Delayed::Job.enqueue(self)
  end
  private :enqueue

  def tarball_path
    Rails.root.join('tmp', reference_tree_id.to_s).to_s
  end
  private :tarball_path
end
