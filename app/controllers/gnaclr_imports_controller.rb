class GnaclrImportsController < ApplicationController
  before_filter :authenticate

  def create
    respond_to do |wants|
      wants.js do
        master_tree = current_user.master_trees.find(params[:master_tree_id])
        gi = GnaclrImporter.create!(:master_tree => master_tree, :source_id => params[:source_id], :url => params[:url])
        Resque.enqueue(GnaclrImporter, gi.id)

        render :json => { :tree_id => reference_tree.id }
      end
      wants.html { head :bad_request }
    end
  end
end
