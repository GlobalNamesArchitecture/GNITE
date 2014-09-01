module Gnite
  module DbData

    def self.populate(environment: "test")
      puts `rake db:seed RAILS_ENV=#{environment}`
    end

    def self.prepopulated_tables
      Dir.entries(csv_dir).select { |e| e.match(/.csv$/) }.map { |e| e[0..-5] }
    end

    private

    def self.csv_dir
      File.join(Rails.root.to_s, "db", "seeds")
    end

  end
end
