module AlternateName
  def self.included(model)
    model.class_eval do
      belongs_to :node
      belongs_to :name

      validates_presence_of :name
      validates_presence_of :node
      validates_uniqueness_of :name_id, scope: :node_id
    end
  end
end
