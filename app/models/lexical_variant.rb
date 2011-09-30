class LexicalVariant < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :name
  belongs_to :lexicalable, :polymorphic => true
  
  delegate :name_string, :to => :name
  
  def rename(new_name_string)
    new_name = Name.where(:name_string => new_name_string).limit(1).first || Name.create(:name_string => new_name_string)
    self.name = new_name
    save
  end

end