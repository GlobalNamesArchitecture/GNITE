class Synonym < ActiveRecord::Base
  include AlternateName
  
  delegate :name_string, to: :name

  def name_string
    self.name.name_string
  end

  def canonical_name
    @canonical_name ||= Gnite::Config.parser.parse(self.name_string, canonical_only: true)
  end
  
  def rename(new_name_string)
    new_name = Name.where(name_string: new_name_string).limit(1).first || Name.create(name_string: new_name_string)
    self.name = new_name
    save
  end

end
