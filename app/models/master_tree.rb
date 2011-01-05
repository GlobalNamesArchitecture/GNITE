class MasterTree < Tree
  has_many :reference_trees
  has_one :deleted_tree
end
