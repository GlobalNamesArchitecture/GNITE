class Users::SessionsController < Devise::SessionsController
  rescue_from BCrypt::Errors::InvalidHash, :with => :redirect_if_old_password
  
  layout "login"
  
  protected
  
  def redirect_if_old_password
    set_flash_message(:failure, :expired)
    redirect_to new_user_password_path
  end

end