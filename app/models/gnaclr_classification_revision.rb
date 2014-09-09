class GnaclrClassificationRevision
  attr_accessor :id, :revision, :url, :tree_id, :tree_id, :message, :committed_date, :file_name,
                :sequence_number, :id, :classification

  def initialize(attributes)
    attributes.symbolize_keys!
    [:revision, :url, :tree_id, :tree_id, :message, :committed_date, :file_name,
           :sequence_number, :id, :classification].each do |key|
      self.send(:"#{key}=", attributes[key])
    end
  end

  def to_hash
    {
      sequence_number: sequence_number,
      url: url,
      file_name: file_name,
      tree_id: tree_id,
      message: message,
      committed_date: committed_date,
      id: id,
    }
  end
end
