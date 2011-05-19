class PushMessagesController < ApplicationController
  before_filter :authenticate
  
  def update
    session_id = (request.headers["X-Session-ID"]) ? request.headers["X-Session-ID"] : ""
    user_details = current_user.serializable_hash(:except => [:encrypted_password, :confirmation_token, :remember_token, :salt, :email_confirmed]).to_json
    message = "{\"subject\" : \"#{params[:subject]}\", \"message\" : \"#{params[:message]}\", \"user\" : " + user_details + ", \"time\" : \"" + Time.new.to_s + "\" }"
    publish = Juggernaut.publish(params[:channel], message, :except => session_id)
    render :json => {:status => "OK"}
  end

end