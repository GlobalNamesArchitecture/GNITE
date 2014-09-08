require 'csv'

unless [:development, :test, :production].include? Rails.env.to_sym
  puts 'Use: bundle exec rake db:seed RAILS_ENV=test|development|production'
  exit
end

class Seeder
  attr :env_dir

  def initialize
    @db = ActiveRecord::Base.connection
    common_dir = File.join(__dir__, 'seeds')
    @env_dir = File.join(common_dir, Rails.env)
  end

  def walk_path(path)
    files = Dir.entries(path).map {|e| e.to_s}.select {|e| e.match /csv$/}
    begin
      files.each do |file|
        add_seeds(file)
      end
    rescue ActiveRecord::StatementInvalid
      raise "Cannot seed database %s" % file
    end
  end

  private 
  
  def add_seeds(file)
    table = file.gsub(/\.csv/, '')
    data = get_data(table, file) 
    @db.execute("truncate table %s" % table) 
    @db.execute("insert ignore into %s values %s" % [table, data]) if data
  end

  def get_data(table, file)
    columns = @db.select_values("show columns from %s" % table)
    ca_index = columns.index("created_at")
    ua_index = columns.index("updated_at")
    csv_args = {:col_sep => "\t"}
    data = CSV.open(File.join(@env_dir, file), csv_args).map do |row|
      res = get_row(row, ca_index, ua_index)
      (columns.size - res.size).times { res << 'null' } 
      res.join(",")
    end rescue []
    data.empty? ? nil : "(%s)" % data.join("), (")
  end

  def get_row(row, ca_index, ua_index)
    res = []
    row.each_with_index do |field, index|
      if [ca_index, ua_index].include? index
        res << 'now()'
      else
        res << @db.quote(field)
      end
    end
    res
  end

end

s = Seeder.new
s.walk_path(s.env_dir)
puts "You added seeds data to %s tables" % Rails.env.upcase


