class TreeSearchesController < ApplicationController
  before_filter :authenticate

  def show
    result = { :status => "Nothing found" }
    nodes = Node.search(params[:name_string], params[:tree_id])   
    result = TreeSearchJsonPresenter.present(nodes) unless nodes.empty?
    render :json => result
  end

end
