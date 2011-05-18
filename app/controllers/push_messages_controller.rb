class PushMessagesController < ApplicationController
  before_filter :authenticate
  
  def update
    session_id = (request.headers["X-Session-ID"]) ? request.headers["X-Session-ID"] : ""
    publish = Juggernaut.publish(params[:channel], params[:message], :except => session_id)
    render :json => {:status => "OK"}
  end

end