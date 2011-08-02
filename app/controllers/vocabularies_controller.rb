class VocabulariesController < ApplicationController
  def show
    vocabulary = Vocabulary.find_by_identifier(params[:id].to_s.downcase)
    
    respond_to do |format|
      format.json do
        render :json => {:metadata => vocabulary, :terms => vocabulary.terms}
      end
    end

  end
end