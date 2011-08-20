require 'redis'
require 'biodiversity'


class ParsleyStore
  #database numbers for Redis
  LOCAL = 1
  SLAVE = 2
  
  def initialize(local_db = LOCAL, slave_db = SLAVE)
    @parser = ScientificNameParser.new
    @local = Redis.new
    @local.select(local_db)
  end

  def parse(scientific_name, opts = {})
    @canonical_only = !!opts[:canonical_only]
    @scientific_name = scientific_name

    parsed_data = get_redis_data
    return parsed_data if parsed_data

    cache_parsed_data(parse_scientific_name)
  end

  private

  def get_redis_data
    if @canonical_only
      begin
        stored = @local.hget(@scientific_name, 'canonical')
      rescue RuntimeError
        @local.flushdb
        stored = nil
      end
      return stored if stored
    else
      stored = @local.get(@scientific_name)
      return JSON.parse(stored, :symbolize_names => true) if stored
    end
  end

  def parse_scientific_name
    begin
      @parser.parse(@scientific_name)
    rescue
      @parser = ScientificNameParser.new
      @parser.parse(@scientific_name) rescue {:scientificName => {:parsed => false, :parser_version => ScientificNameParser::VERSION, :anonical => nil, :verbatim => @scientific_name}}
    end
  end

  def cache_parsed_data(parsed_data)
    if @canonical_only
      @local.hset @scientific_name, 'parsed',  parsed_data[:scientificName][:parsed]
      @local.hset @scientific_name, 'parser_version', parsed_data[:scientificName][:parser_version]
      @local.hset @scientific_name, 'canonical', parsed_data[:scientificName][:canonical]
      parsed_data[:scientificName][:canonical]
    else
      serialized = parsed_data.to_json
      @local.set @scientific_name, serialized
      parsed_data
    end
  end

end
