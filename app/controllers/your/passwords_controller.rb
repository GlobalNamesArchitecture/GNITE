class Your::PasswordsController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    if current_user.update_password(params[:user][:password],
                                    params[:user][:password_confirmation])
      flash[:success] = "Password changed."
      redirect_to root_url
    else
      @user = current_user
      render :action => :edit
    end
  end
end
