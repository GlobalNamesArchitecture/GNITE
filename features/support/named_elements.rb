module NamedElementHelper
  def element_for(named_element)
    case named_element
    when /the right panel header/
      "#treewrap-right .breadcrumbs"
    when /a spinner/
      ".spinner"
    when /the navigation bar/
      "#navbar"
    when /the master tree title field/
      "#master_tree_title"
    when /the gnaclr import button/
      '#import-gnaclr-button'
    when /the Scientific Name tab/
      'li#scientific-name-tab'
    when /the signout link/
      "a[href^='#{sign_out_path}']"
    when /any reference tree nodes/
      ".reference-tree .jstree-leaf"
    else
      raise "Can't find mapping for \"#{named_element}\"."
    end
  end

  include ActionController::RecordIdentifier
end
World(NamedElementHelper)
