class TreeSearchesController < ApplicationController
  before_filter :authenticate
  
  def show
    names = Node.search(params[:name_string].downcase, params[:tree_id])
    result = []
    names.each do |name|
      result << Node.find_by_name_id(name.id)
    end
    render :json => TreeSearchJsonPresenter.present(result)
  end

end