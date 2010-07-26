class SessionsController < Clearance::SessionsController
  private

  def url_after_create
    trees_url
  end
end
