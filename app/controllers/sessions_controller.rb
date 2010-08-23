class SessionsController < Clearance::SessionsController
  layout 'login'

  private

  def url_after_create
    master_trees_url
  end
end
