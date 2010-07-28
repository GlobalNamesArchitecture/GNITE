class UsersController < Clearance::UsersController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:success] = "You have successfully updated your profile"
      redirect_to :root
    else
      render :edit
    end
  end
end
