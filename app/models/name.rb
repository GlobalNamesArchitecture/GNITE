class Name < ActiveRecord::Base
  validates_presence_of   :name_string
  validates_uniqueness_of :name_string

  has_many :nodes

  def used_only_once?
    nodes.count == 1
  end

  def name_string!(new_name_string)
    self.name_string = new_name_string
    self.save!
  end
end
