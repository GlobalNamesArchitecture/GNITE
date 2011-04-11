class GnaclrImportsController < ApplicationController
  before_filter :authenticate

  def create
    respond_to do |wants|
      wants.js do
        reference_tree, is_new_tree = get_reference_tree(master_tree)
        if is_new_tree
          gi = GnaclrImporter.create!(:reference_tree => reference_tree, :url => params[:url])
          Resque.enqueue(GnaclrImporter, gi.id)
        render :json => { :tree_id => reference_tree.id }
      end
      wants.html { head :bad_request }
    end
  end

  private

  def get_reference_tree
    master_tree = current_user.master_trees.find(params[:master_tree_id])

  end
end
