class ImportsController < ApplicationController
  before_filter :authenticate

  def new
    render :layout => 'right_tree'
  end
end
