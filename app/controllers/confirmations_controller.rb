class ConfirmationsController < Clearance::ConfirmationsController

  private

  def url_after_create
    trees_url
  end

end
