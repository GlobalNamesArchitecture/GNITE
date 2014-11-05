class Admin::MasterTreesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  add_breadcrumb 'Administration', 'admin_path'
  add_breadcrumb 'Trees', 'admin_master_trees_path', only: :edit
  
  layout :get_layout
  
  def index
    page = (params[:page]) ? params[:page] : 1
    @master_trees = MasterTree.includes(:user)
                 .paginate(page: page, per_page: 25)
                 .order("title")
  end
  
  def edit
    @master_tree = MasterTree.includes(:master_tree_contributors).find(params[:id])
  end
  
  def show
    redirect_to :edit_admin_master_tree
  end
  
  def update
    @master_tree = MasterTree.includes(:master_tree_contributors).find(params[:id])

    if params[:cancel]
      redirect_to admin_master_trees_url
    else
      params[:master_tree][:master_tree_contributor_ids].reject!(&:blank?).collect!{ |s| s.to_i }.compact!
      if @master_tree.update(tree_params)
        flash[:notice] = "Working Tree successfully updated"
      end
      redirect_to :edit_admin_master_tree
    end
  end
  
  private
  
  def get_layout
    if action_name == "edit" || action_name == "update"
      "master_trees"
    else
      "application"
    end
  end

  def tree_params
    params.require(:master_tree).permit(:title, :citation, :abstract, :publication_date, :creative_commons, :master_tree_contributor_ids => [])
  end

end