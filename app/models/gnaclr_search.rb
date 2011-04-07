class GnaclrSearch

  attr_accessor :search_term
  def initialize(opts)
    raise ArgumentError unless opts.has_key?(:search_term)
    @search_term = URI.escape(opts[:search_term])
  end

  def results
    @results ||= search
  end

  private

  def search
    path = Gnite::Config.gnaclr_url + "/search?format=json&show_revisions=true&search_term=#{search_term}"
    begin
      json = open(path).read
    rescue OpenURI::HTTPError
      raise Gnite::ServiceUnavailable
    end
    Yajl::Parser.new.parse(json)
  end

end
