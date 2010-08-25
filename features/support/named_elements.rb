module NamedElementHelper
  def element_for(named_element)
    case named_element
    when /the right panel header/
      "#treewrap-right .metadata-header"

    else
      raise "Can't find mapping for \"#{named_element}\"."
    end
  end

  include ActionController::RecordIdentifier
end
World(NamedElementHelper)
