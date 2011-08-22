module Gnite
  module DbData

    def self.populate
      Dir.entries(csv_dir).each do |file|
        next if file[-4..-1] != '.csv'
        table_name = file.gsub(/.csv$/, '')
        ::Node.connection.execute "truncate #{table_name}"  
        ::Node.connection.execute "load data infile '#{File.join(csv_dir, file)}' into table #{table_name} character set utf8"  
      end
    end

    def self.prepopulated_tables
      Dir.entries(csv_dir).select { |e| e.match(/.csv$/) }.map { |e| e[0..-5] }
    end

    private

    def self.csv_dir
      File.join(Rails.root.to_s, 'db', 'csv')
    end

  end
end
