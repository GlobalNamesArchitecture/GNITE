class GnaclrImportsController < ApplicationController
  before_filter :authenticate_user!

  def create
    respond_to do |wants|
      wants.js do
        reference_tree, is_new_tree = get_reference_tree
        if is_new_tree
          gi = GnaclrImporter.create!(:reference_tree => reference_tree, :url => params[:url])
          Resque.enqueue(GnaclrImporter, gi.id)
        end
        render :json => { :tree_id => reference_tree.id }
      end
      wants.html { head :bad_request }
    end
  end

  private

  def get_reference_tree
    master_tree = current_user.master_trees.find(params[:master_tree_id])
    reference_tree = ReferenceTree.find_by_revision(params[:revision])
    is_new_tree = false
    unless reference_tree
      reference_tree = ReferenceTree.create(:title            => params[:title],
                                            :publication_date => params[:publication_date],
                                            :revision         => params[:revision],
                                            :state            => 'importing')
      is_new_tree = true
    end
    if ReferenceTreeCollection.find_all_by_master_tree_id_and_reference_tree_id(master_tree.id, reference_tree.id).empty?
      ReferenceTreeCollection.create!(:master_tree => master_tree, :reference_tree => reference_tree)
    end
    [reference_tree, is_new_tree]
  end
end
