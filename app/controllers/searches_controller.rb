class SearchesController < ApplicationController
  before_filter :authenticate

  def show
    respond_to do |wants|
      wants.js do
        begin
          @results     = Search.new(:search_term => params[:search_term]).results
          @master_tree = current_user.master_trees.find(params[:master_tree_id])
        rescue Search::ServiceUnavailable
          head :service_unavailable
          return
        end
        render :show, :layout => false
      end
      wants.html { head :bad_request }
    end
  end
end
