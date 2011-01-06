# encoding: utf-8
class GnaclrPublisher < ActiveRecord::Base
  belongs_to :master_tree

  def self.perform(gnaclr_publisher_id)
    gp = GnaclrPublisher.find(gnaclr_publisher_id)
    gi.publish
  end

  def publish
    dwca_file = master_tree.create_darwin_core_archive
    RestClient.post Gnite::Config.gnaclr_url + '/classification', :myfile => File.new(dwca_file, 'rb'), :uuid => master_tree.uuid
  end
end

