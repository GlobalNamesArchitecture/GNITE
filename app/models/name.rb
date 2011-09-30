class Name < ActiveRecord::Base
  validates_presence_of   :name_string
  validates_uniqueness_of :name_string

  has_many :nodes
  has_many :lexical_variants
end
