class Node < ActiveRecord::Base
  validates_presence_of :name, :tree_id
  belongs_to :tree
  belongs_to :name

  has_many :synonyms
  has_many :vernacular_names

  before_create :check_parent_id_for_nil
  before_update :check_parent_id_for_nil


  delegate :name_string, :to => :name

  def self.find_by_id_for_user(id_to_find, user)
    # If we just called user.master_tree_ids here,
    # AR wouldn't load all the tree columns, causing Tree#after_initialize to fail when trying to read self.uuid
    tree_ids = user.master_trees.map(&:id) | user.reference_trees.map(&:id) | user.deleted_trees.map(&:id)
    find(:first, :conditions => ["id = ? and tree_id in (?)", id_to_find, tree_ids])
  end

  def self.roots(tree_id)
    Node.find_by_sql("select * from nodes where parent_id is null and tree_id = #{tree_id}")
  end

  def self.search(search_string, tree_id)
    names = []
    clean_search = "%#{search_string}%"
    Name.find(:all, :joins => :nodes, :conditions => ['names.name_string LIKE ? AND nodes.tree_id = ?', clean_search, tree_id] )
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

  def synonym_name_strings
    synonyms.all(:include => :name).map(&:name).compact.map(&:name_string).tap do |name_strings|
      name_strings << 'None' if name_strings.empty?
    end
  end

  def vernacular_name_strings
    vernacular_names.all(:include => :name).map(&:name).compact.map(&:name_string).tap do |name_strings|
      name_strings << 'None' if name_strings.empty?
    end
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
    Node.select(select_params)
      .where(:parent_id => id)
      .joins(:name)
      .order("name_string")
      .readonly(false) #select and join return readonly objects, override that here
  end

  def has_children?
    Node.select(:id).where(:parent_id => id).limit(1).exists?
  end

  def ancestors
    node, nodes = self, []
    nodes << node = node.parent while node.parent
    nodes.pop
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
end
