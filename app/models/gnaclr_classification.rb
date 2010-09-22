class GnaclrClassification
  URL = 'gnaclr.globalnames.org'

  attr_accessor :title, :authors, :description, :updated, :uuid, :revisions, :file_url

  def initialize(new_attributes = {})
    new_attributes.symbolize_keys!

    [:title, :authors, :description, :updated, :uuid, :file_url].each do |key|
      self.send(:"#{key}=", new_attributes[key])
    end

    self.revisions = (new_attributes[:revisions] || []).map do |revision_attributes|
      GnaclrClassificationRevision.new(revision_attributes.merge(:classification => self))
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
      :uuid        => uuid,
      :file_url    => file_url,
      :revisions   => revisions.map(&:to_hash)
    }
  end

  def ==(other)
    attributes == other.attributes
  end

  def to_param
    uuid
  end

  def add_revision_from_attributes(revision_attributes)
    (self.revisions ||= []) << GnaclrClassificationRevision.new(revision_attributes.merge(:classification => self))
  end

  def revision_count
    self.revisions.count
  end

  private

  def self.from_xml(xml)
    struct = Crack::XML.parse(xml)

    struct["hash"]["classifications"].map do |hash|
      new(hash)
    end
  end
end
