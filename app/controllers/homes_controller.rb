class HomesController < ApplicationController
  def show
    flash.keep

    if signed_in?
      redirect_to trees_url
    else
      redirect_to sign_in_url
    end
  end
end
