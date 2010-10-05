class GnaclrImportsController < ApplicationController
  before_filter :authenticate

  def create
    respond_to do |wants|
      wants.js do
        master_tree    = current_user.master_trees.find(params[:master_tree_id])
        reference_tree = current_user.reference_trees.create(:title          => params[:title],
                                                             :master_tree_id => master_tree.id,
                                                             :source_id      => params[:source_id],
                                                             :state          => 'importing')

        GnaclrImporter.new(:reference_tree => reference_tree,
                           :url            => params[:url])

        render :json => { :tree_id => reference_tree.id }
      end
      wants.html { head :bad_request }
    end
  end
end
