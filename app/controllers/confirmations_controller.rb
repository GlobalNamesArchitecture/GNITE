class ConfirmationsController < Clearance::ConfirmationsController

  private

  def url_after_create
    master_trees_url
  end

end
