# encoding: utf-8
class GnaclrPublisher < ActiveRecord::Base
  belongs_to :master_tree
  @queue = :gnite_not_destructive

  def self.perform(gnaclr_publisher_id)
    gp = GnaclrPublisher.find(gnaclr_publisher_id)
    gp.publish
  end

  def publish
    dwca_file = master_tree.create_darwin_core_archive
    RestClient.post("#{Gnite::Config.gnaclr_url}/classifications", uuid: master_tree.uuid, file: File.new(dwca_file, 'rb') )
  end
end

