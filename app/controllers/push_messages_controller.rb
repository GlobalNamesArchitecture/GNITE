class PushMessagesController < ApplicationController
  before_filter :authenticate
  
  def update
    session_id = (request.headers["X-Session-ID"]) ? request.headers["X-Session-ID"] : ""
    message = "{\"#{params[:subject]}\" : \"#{params[:message]}\", \"time\" : \"" + Time.new.to_s + "\" }"
    publish = Juggernaut.publish(params[:channel], message, :except => session_id)
    render :json => {:status => "OK"}
  end

end