class GnaclrImporterLogger
  attr_reader :subscriptions

  def initialize
    @subscriptions = {}
  end

  def info(message)
    dwc_object_id, message = message.split("|")[1..2]
    gnaclr_importer_id = @subscriptions[dwc_object_id.to_i]
    # raise "The message should contain numeric object_id for the DarwinCore object" unless dwc_object_id.to_i.to_s == dwc_object_id
    if dwc_object_id && gnaclr_importer_id
      GnaclrImporterLog.create(:gnaclr_importer_id => gnaclr_importer_id, :message => message)
      gi = GnaclrImporter.find(gnaclr_importer_id)
      gi.message = message
      gi.save!
    end
  end

  def subscribe(opts)
    dwc_object_id = opts[:dwc_object_id]
    gnaclr_importer_id =  opts[:gnaclr_importer_id]
    @subscriptions[dwc_object_id] = gnaclr_importer_id
  end

  def unsubscribe(dwc_object_id)
    @subscriptions.delete(dwc_object_id)
  end

end
