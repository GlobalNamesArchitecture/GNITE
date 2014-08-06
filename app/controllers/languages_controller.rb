class LanguagesController < ApplicationController
  
  def show
    
    @languages = Language.where("iso_639_2 != ''")
    
    respond_to do |format|
      format.json do
        render :json => { :terms => @languages.map{ |k| { :id => k.id, :term => k.name } } }
      end
    end
  end
  
end