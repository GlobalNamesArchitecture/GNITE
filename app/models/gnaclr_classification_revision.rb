class GnaclrClassificationRevision
  attr_accessor :url, :file_name, :tree_id

  def initialize(attributes)
    attributes.symbolize_keys!

    [:url, :file_name, :tree_id].each do |key|
      self.send(:"#{key}=", attributes[key])
    end
  end
end
