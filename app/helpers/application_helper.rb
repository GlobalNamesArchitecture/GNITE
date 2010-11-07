module ApplicationHelper
  def body_class
    qualified_controller_name = controller.controller_path.gsub('/','-')
    "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"
  end

  def meta_description
    "GNITE is a web application that allows biologists and taxonomists to view, edit, and add data related to the classification of all known biological species."
  end
end
