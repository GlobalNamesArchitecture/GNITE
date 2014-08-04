module NamedElementHelper
  def element_for(named_element)
    case named_element
    when /the right panel header/
      "#treewrap-right #new-tab .breadcrumbs"
    when /a spinner/
      ".spinner"
    when /the navigation bar/
      "#navbar"
    when /the master tree title field/
      "#master_tree_title_input"
    when /the gnaclr import button/
      "#import-gnaclr-button"
    when /the Scientific Name tab/
      "li#scientific-name-tab"
    when /the signout link/
      "a[href^='#{destroy_user_session_path}']"
    when /any reference tree nodes/
      ".reference-tree .jstree-leaf"
    when /toolbar/
      "#toolbar"
    when /the dialog box/
      ".ui-dialog-content"
    when /the master tree metadata panel/
      "#treewrap-main .tree-background .node-metadata"
    when /the metadata panel context menu/
      "#ddsmoothmenu-context"
    when /the chat window/
      "#chat-messages-wrapper"
    when /the reference trees tab/
      "#reference-trees"
    else
      named_element
    end
  end

  include ActionController::RecordIdentifier
end
World(NamedElementHelper)
