class HomesController < ApplicationController
  def show
    flash.keep

    if user_signed_in?
      redirect_to master_trees_url
    else
      redirect_to new_user_session_url
    end
  end
end
