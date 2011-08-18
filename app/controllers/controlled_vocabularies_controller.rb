class ControlledVocabulariesController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render :json => { :vocabularies => ControlledVocabulary.all }
      end
    end
  end
  
  def show
    @vocabulary = ControlledVocabulary.find_by_identifier(params[:id].to_s.downcase)
    
    if params[:q]
      @terms = @vocabulary.controlled_terms.all(:conditions => ["controlled_terms.name LIKE ?", params[:q] + '%' ])
    else
      @terms = @vocabulary.controlled_terms
    end
    
    respond_to do |format|
      format.json do
        render :json => { :metadata => @vocabulary, :terms => @terms }
      end
    end
  end
  
end