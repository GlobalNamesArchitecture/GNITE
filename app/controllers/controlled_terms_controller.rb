class ControlledTermsController < ApplicationController
  def show
    term = ControlledTerm.find_by_identifier(params[:id].to_s.downcase)
    
    respond_to do |format|
      format.json do
        render :json => term
      end
    end

  end
end