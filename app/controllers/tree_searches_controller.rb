class TreeSearchesController < ApplicationController
  before_filter :authenticate
  
  def show
    result = { :status => "Nothing found" }
    clean_search = "%#{params[:name_string].downcase}%"
    nodes = Node.find(:all, :joins => :name, :conditions => ['names.name_string LIKE ? AND nodes.tree_id = ?', clean_search, params[:tree_id]], :order => 'names.name_string' )
    result = TreeSearchJsonPresenter.present(nodes) unless nodes.empty?
    render :json => result
  end

end