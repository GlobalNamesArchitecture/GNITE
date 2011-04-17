class TreeSearchesController < ApplicationController
  before_filter :authenticate
  
  def show
    names = Node.search(params[:name_string].downcase, params[:tree_id])
    result = []
    names.each do |name|
      result << Node.find(:all, :conditions => {:name_id => name.id, :tree_id => params[:tree_id]})
    end
    render :json => (result.length > 0) ? TreeSearchJsonPresenter.present(result.first.uniq) : { :status => "Nothing found" }
  end

end