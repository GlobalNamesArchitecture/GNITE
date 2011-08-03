class ControlledVocabulariesController < ApplicationController
  def show
    vocabulary = ControlledVocabulary.find_by_identifier(params[:id].to_s.downcase)
    
    respond_to do |format|
      format.json do
        render :json => {:metadata => vocabulary, :terms => vocabulary.controlled_terms}
      end
    end

  end
end