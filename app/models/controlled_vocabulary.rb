class ControlledVocabulary < ActiveRecord::Base
  has_many :controlled_terms
end