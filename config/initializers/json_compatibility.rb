require 'yajl/json_gem'

module JSON
  def self.parse(str, opts=JSON.default_options)
    opts[:symbolize_keys] = opts[:symbolize_names] if opts[:symbolize_names]
    begin
      Yajl::Parser.parse(str, opts)
    rescue Yajl::ParseError => e
      raise JSON::ParserError, e.message
    end
  end
end
