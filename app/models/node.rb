class Node < ActiveRecord::Base
  validates_presence_of :name, :tree_id
  belongs_to :tree
  belongs_to :name

  has_many :bookmarks
  has_many :synonyms
  has_many :vernacular_names
  has_many :lexical_variants, :as => :lexicalable
  has_many :merge_events, :foreign_key => :primary_node_id
  has_many :merge_events, :foreign_key => :secondary_node_id
  has_many :merge_result_primaries
  has_many :merge_result_secondaries

  before_create :check_parent_id_for_nil
  before_update :check_parent_id_for_nil

  delegate :name_string, :to => :name

  include Gnite::NodeHierarchy
  include Gnite::NodeMerge

  def self.search(search_string, tree_id)
    clean_search_string = "%#{search_string}%"
    clean_tree_id = "#{tree_id}"
    names = Name.find(:all, :conditions => ['names.name_string LIKE ?', clean_search_string.downcase])
    nodes = []
    names.each do |name|
      node = Node.find_by_name_id(name, :conditions => {:tree_id => clean_tree_id.to_i})
      nodes <<  node unless node.nil?
    end
    nodes
  end

  def canonical_name
    @canonical_name ||= Gnite::Config.parser.parse(self.name_string, :canonical_only => true)
  end

  def synonym_data
    res = synonyms.all.map { |s| { :name_string => s.name.name_string, :metadata => symbolize_keys(s.attributes) } }
    res.sort { |a,b| a[:name_string] <=> b[:name_string] }
  end
  
  def vernacular_data
    res = vernacular_names.all.map { |v| { :name_string => v.name.name_string, :metadata => v.language.nil? ? symbolize_keys(v.attributes.merge(:language => {:id => nil, :name => nil})) : symbolize_keys(v.attributes.merge(:language => v.language.attributes)) } }
    res.sort { |a,b| a[:name_string] <=> b[:name_string] }
  end
  
  def lexical_data
    res = lexical_variants.all.map { |l| { :name_string => l.name.name_string, :metadata => symbolize_keys(l.attributes) } }
    res.sort { |a,b| a[:name_string] <=> b[:name_string] }
  end
  
  def rank_string
    rank_string = rank.to_s.strip
    rank_string = 'None' if rank_string.empty?
    rank_string
  end

  def rename(new_name_string)
    new_name = Name.where(:name_string => new_name_string).limit(1).first || Name.create(:name_string => new_name_string)
    self.name = new_name
    save
  end
  
  private

  def check_parent_id_for_nil
    return if self.parent_id || !self.tree.root
    self.parent_id = self.tree.root.id
  end

  #TODO feels like a general helper
  def symbolize_keys(arg)
    case arg
    when Array
      arg.map { |elem| symbolize_keys elem }
    when Hash
      Hash[
        arg.map { |key, value|  
          k = key.is_a?(String) ? key.to_sym : key
          v = symbolize_keys value
          [k,v]
        }]
    else
      arg
    end
  end

end
