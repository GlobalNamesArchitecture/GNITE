class LanguagesController < ApplicationController
  
  def show
    
    if params[:q]
      @languages = Language.all(:conditions => ["name LIKE ? AND iso_639_2 <> ''", params[:q] + '%' ])
    else
      @languages = Language.all(:conditions => ["iso_639_2 <> ''"])
    end
    
    respond_to do |format|
      format.json do
        render :json => { :terms => @languages.map{ |k| { :id => k.id, :term => k.name } } }
      end
    end
  end
  
end