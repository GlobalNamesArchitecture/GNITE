class GnaclrImporter
  class InvalidDwcArchiveError < Exception; end

  attr_reader   :dwc, :id_index, :name_index, :parent_id_index
  attr_accessor :reference_tree_id, :url

  def initialize(opts)
    @reference_tree_id = opts[:reference_tree_id]
    @url               = opts[:url]
    enqueue
  end

  def fetch_tarball
    Kernel.system("curl -s #{url} > #{tarball_path}")
  end

  def read_tarball
    @dwc             = DarwinCore.new(tarball_path)
    @id_index        = dwc.core.data[:id][:attributes][:index]
    @name_index      = dwc_field_index('http://rs.tdwg.org/dwc/terms/scientificName')
    @parent_id_index = dwc_field_index('http://rs.tdwg.org/dwc/terms/higherTaxonID') ||
                         dwc_field_index('http://rs.tdwg.org/dwc/terms/parentNameUsageID')
  end

  def store_tree
    data, errors = dwc.core.read
    raise GnaclrImporter::InvalidDwcArchiveError if errors.any?
    id_hash = {}
    data.each do |row|
      node = Node.create!(:name   => row[name_index],
                        :tree_id => reference_tree_id)
      id_hash.store(row[id_index], node.id)
    end
    if parent_id_index.present?
      data.each do |row|
        node           = Node.find(id_hash[row[id_index]])
        node.parent_id = id_hash[row[parent_id_index]]
        node.save!
      end
    end
  end

  def perform
    fetch_tarball
    read_tarball
    store_tree
  end

  def enqueue
    Delayed::Job.enqueue(self)
  end
  private :enqueue

  def tarball_path
    Rails.root.join('tmp', reference_tree_id.to_s).to_s
  end
  private :tarball_path

  def dwc_field_index(uri)
    dwc_fields       = dwc.core.data[:field].map { |field| field[:attributes] }
    field_attributes = dwc_fields.detect { |attributes| attributes[:term] == uri }

    if field_attributes
      field_attributes[:index]
    end
  end
  private :dwc_field_index
end
