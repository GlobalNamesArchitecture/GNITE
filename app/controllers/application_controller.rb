class ApplicationController < ActionController::Base
  include Clearance::Authentication
  protect_from_forgery
  layout 'application'

  def authenticate
    deny_access("You must sign in to view that page") unless signed_in?
  end
end
