class VernacularName < ActiveRecord::Base
  belongs_to :language
  include AlternateName
end
