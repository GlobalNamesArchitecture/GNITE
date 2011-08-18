class LanguagesController < ApplicationController
  
  def show
    
    if params[:q]
      @languages = Language.all(:conditions => ["name LIKE ? AND iso_639_2 <> ''", params[:q] + '%' ])
    else
      @languages = Language.all
    end
    
    respond_to do |format|
      format.json do
        render :json => @languages
      end
    end
  end
  
end