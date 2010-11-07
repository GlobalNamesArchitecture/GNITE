class GnaclrImporterLogger
  attr_reader :subscriptions

  def initialize
    @subscriptions = {}
  end

  def info(message)
    dwc_object_id, message = message.split("|")[1..2]
    ref_tree_id = @subscriptions[dwc_object_id.to_i]
    # raise "The message should contain numeric object_id for the DarwinCore object" unless dwc_object_id.to_i.to_s == dwc_object_id
    if dwc_object_id && ref_tree_id 
      GnaclrImporterLog.create(:reference_tree_id => ref_tree_id, :message => message)
      gi = GnaclrImporter.find_all_by_reference_tree_id(ref_tree_id)
      unless gi.empty?
        gi = gi.last
        gi.message = message
        gi.save!
      end
    end
  end

  def subscribe(opts)
    dwc_object_id = opts[:dwc_object_id]
    ref_tree_id =  opts[:reference_tree_id]
    # raise "Incompatible data" unless dwc_object_id.is_a?(Fixnum) && tree.is_a?(Tree)
    @subscriptions[dwc_object_id] = ref_tree_id
  end

  def unsubscribe(dwc_object_id)
    @subscriptions.delete(dwc_object_id)
  end

end
