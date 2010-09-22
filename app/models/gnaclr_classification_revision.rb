class GnaclrClassificationRevision
  attr_accessor :url, :file_name, :tree_id, :message, :number, :classification

  def initialize(attributes)
    attributes.symbolize_keys!

    [:url, :file_name, :tree_id, :message, :number, :classification].each do |key|
      self.send(:"#{key}=", attributes[key])
    end
  end

  def to_hash
    {
      :number     => number,
      :url        => url,
      :file_name  => file_name,
      :tree_id    => tree_id,
      :message    => message
    }
  end
end
