class ReferenceTreeCollection < ActiveRecord::Base
  belongs_to :reference_tree
  belongs_to :master_tree
  validates_presence_of :reference_tree
  validates_presence_of :master_tree
end
