class Synonym < ActiveRecord::Base
  include AlternateName

  def name_string
    self.name.name_string
  end

  def canonical_name
    @canonical_name ||= Gnite::Config.parser.parse(self.name_string, :canonical_only => true)
  end

end
