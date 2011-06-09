class Node < ActiveRecord::Base
  validates_presence_of :name, :tree_id
  belongs_to :tree
  belongs_to :name

  has_many :bookmarks
  has_many :synonyms
  has_many :vernacular_names
  has_many :merge_events, :foreign_key => :primary_node_id
  has_many :merge_events, :foreign_key => :secondary_node_id
  has_many :merge_result_primaries
  has_many :merge_result_secondaries


  before_create :check_parent_id_for_nil
  before_update :check_parent_id_for_nil

  delegate :name_string, :to => :name

  def self.roots(tree_id)
    Node.find_by_sql("select * from nodes where parent_id is null and tree_id = #{tree_id}")
  end

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

  def deep_copy_to(tree)
    copy = self.clone
    copy.tree = tree
    copy.save!

    children.each do |child|
      child_copy = child.deep_copy_to(tree)
      child_copy.parent = copy
      child_copy.save!
    end

    vernacular_names.each do |vernacular_name|
      vernacular_name_copy = vernacular_name.clone
      vernacular_name_copy.node = copy
      vernacular_name_copy.save!
    end

    synonyms.each do |synonym|
      synonym_copy = synonym.clone
      synonym_copy.node = copy
      synonym_copy.save!
    end

    copy.reload
  end

  def rank_string
    rank_string = rank.to_s.strip
    rank_string = 'None' if rank_string.empty?
    rank_string
  end
  
  def synonym_data
    return [{:name_string => 'None', :metadata => []}] unless synonyms.exists?
    synonyms.all.map { |s| { :name_string => s.name.name_string, :metadata => symbolize_keys(s.attributes) } }
  end
  
  def vernacular_data
    return [{:name_string => 'None', :metadata => []}] unless vernacular_names.exists?
    vernacular_names.all.map { |v| { :name_string => v.name.name_string, :metadata => symbolize_keys(v.attributes.merge(:language => v.language.attributes)) } }
  end

  def parent()
    return unless parent_id
    Node.find(parent_id)
  end

  def parent=(node)
    self.update_attributes(:parent_id => node.id)
  end

  def children(select_params = '')
    select_params = select_params.empty? ? '`nodes`.*' : select_params.split(',').map { |p| '`nodes`.' + p.strip }.join(', ')
    nodes = Node.select(select_params)
      .where(:parent_id => id)
      .joins(:name)
      .order("name_string")
      .readonly(false) #select and join return readonly objects, override that here
    nodes
  end

  def has_children?
    Node.select(:id).where(:parent_id => id).limit(1).exists?
  end

  def child_count
    Node.select(:id).where(:parent_id => id).size
  end

  def ancestors(options = {})
    node, nodes = self, []
    nodes << node = node.parent while node.parent
    nodes.pop unless options[:with_tree_root]
    nodes.reverse
  end

  def rename(new_name_string)
    new_name = Name.where(:name_string => new_name_string).limit(1).first || Name.create(:name_string => new_name_string)
    self.name = new_name
    save
  end

  def destroy_with_children
    nodes_to_delete = [id]
    collect_children_to_delete(nodes_to_delete)
    Node.transaction do
      nodes_to_delete.each_slice(Gnite::Config.batch_size) do |ids|
        delete_nodes_records(ids)
      end
    end
  end

  def descendants
    nodes = []
    children.each do |child|
      nodes << child.descendants
    end
  end

  #called externally, so it has to be public
  def collect_children_to_delete(nodes_to_delete)
    children('id').each do |c|
      nodes_to_delete << c.id
      c.collect_children_to_delete(nodes_to_delete)
    end
  end

  private

  def check_parent_id_for_nil
    return if self.parent_id || !self.tree.root
    self.parent_id = self.tree.root.id
  end

  def delete_nodes_records(ids)
    delete_ids = ids.join(',')
    %w{vernacular_names synonyms}.each do |table|
      Node.connection.execute("
        DELETE
        FROM #{table}
        WHERE node_id IN (#{delete_ids})")
    end
    Node.connection.execute("DELETE FROM nodes WHERE id IN (#{delete_ids})")
  end
  
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
