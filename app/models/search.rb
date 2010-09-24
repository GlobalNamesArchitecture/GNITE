class Search
  URL = 'gnaclr.globalnames.org'

  attr_accessor :search_term
  def initialize(opts)
    raise ArgumentError unless opts.has_key?(:search_term)
    @search_term = URI.escape(opts[:search_term])
  end

  def results
    @results ||= search
  end

  def search
    path     = "http://#{URL}/search?format=xml&show_revisions=true&search_term=#{search_term}"
    xml      = open(path).read
    Crack::XML.parse(xml)['hash']
  end
  private :search
end

