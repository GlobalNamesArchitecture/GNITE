class HomesController < ApplicationController
  def show
    redirect_to sign_in_path
  end
end
