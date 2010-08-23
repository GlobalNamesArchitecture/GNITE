class GnaclrClassification
  URL = 'gnaclr.globalnames.org'

  attr_accessor :title, :authors, :description, :updated, :uuid, :revisions

  def initialize(new_attributes = {})
    new_attributes.symbolize_keys!

    self.revisions = []

    [:title, :authors, :description, :updated, :uuid].each do |key|
      self.send(:"#{key}=", new_attributes[key])
    end
  end

  def self.all
    path = "http://#{URL}/classifications?format=xml"
    xml = open(path).read
    from_xml(xml)
  end

  def self.find_by_uuid(uuid)
    all.detect do |classification|
      classification.uuid == uuid
    end
  end

  def attributes
    {
      :title       => title,
      :authors     => authors,
      :description => description,
      :updated     => updated,
      :uuid        => uuid
    }
  end

  def ==(other)
    attributes == other.attributes
  end

  def to_param
    uuid
  end

  private

  def self.from_xml(xml)
    struct = Crack::XML.parse(xml)

    struct["hash"]["classifications"].map do |hash|
      new(hash)
    end
  end
end
