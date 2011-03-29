class DeletedTreesController < ApplicationController
  before_filter :authenticate

  def show
    respond_to do |format|
      format.json do
        @deleted_tree = DeletedTree.find(params[:id])
        render :partial => 'deleted_tree'
      end
      format.html { head :bad_request }
    end
  end
end