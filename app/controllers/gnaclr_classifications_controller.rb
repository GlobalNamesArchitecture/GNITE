class GnaclrClassificationsController < ApplicationController
  before_filter :authenticate

  def index
    @gnaclr_classifications = GnaclrClassification.all
    render :layout => 'right_tree'
  end

  def show
    @gnaclr_classification = GnaclrClassification.find_by_uuid(params[:id])
    render :layout => 'right_tree'
  end
end
