class ControlledVocabulariesController < ApplicationController

  def show
    vocabulary = ControlledVocabulary.find_by_identifier(params[:id].to_s.downcase)
    terms = vocabulary ? vocabulary.controlled_terms.order(:name) : [ ]

    respond_to do |format|
      format.json do
        render :json => { :metadata => vocabulary,
                          :terms => terms.map{ |k| { :id => k.id, :term => k.name } } }
      end
    end
  end

end