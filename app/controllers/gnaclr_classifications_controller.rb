class GnaclrClassificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @master_tree = current_user.master_trees.find(params[:master_tree_id])
    @gnaclr_classifications = GnaclrClassification.all
    render :layout => 'right_tree'
  end

  def show
    @master_tree = current_user.master_trees.find(params[:master_tree_id])
    @gnaclr_classification = GnaclrClassification.find_by_uuid(params[:id])
    render :layout => 'right_tree'
  end
end
