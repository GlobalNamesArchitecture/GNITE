class MergeTreesController < ApplicationController
  before_filter :authenticate

  def show
    respond_to do |format|
      format.json do
        @merge_tree = MergeTree.find(params[:id])
        render :partial => 'merge_tree'
      end
      format.html { head :bad_request }
    end
  end
end