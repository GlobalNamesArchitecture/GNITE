class Users::RegistrationsController < Devise::RegistrationsController
  layout :get_layout

  private
  
  def get_layout
    if action_name == "edit" || action_name == "update"
      "application"
    else
      "login"
    end
  end
  
  def after_update_path_for(resource)
    edit_user_registration_path
  end
 
end