class VernacularName < ActiveRecord::Base
  belongs_to :language
  include AlternateName
  
  delegate :name_string, to: :name
  
  def rename(new_name_string)
    new_name = Name.where(name_string: new_name_string).limit(1).first || Name.create(name_string: new_name_string)
    self.name = new_name
    save
  end
end
