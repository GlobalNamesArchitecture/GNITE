class SessionsController < Clearance::SessionsController
  layout 'login'

  private

  def url_after_create
    trees_url
  end
end
