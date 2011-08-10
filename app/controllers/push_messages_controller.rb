class PushMessagesController < ApplicationController
  before_filter :authenticate
  
  def update
    session_id = (request.headers["X-Session-ID"]) ? request.headers["X-Session-ID"] : ""
    user = { :id => current_user.id, :email => current_user.email }
    message = Sanitize.clean("#{params[:message]}", Sanitize::Config::BASIC)
    message = { :subject => "#{params[:subject]}", :message => message, :user => user, :time => Time.new.to_s }.to_json 
    publish = Juggernaut.publish(params[:channel], message, :except => session_id)
    render :json => {:status => "OK"}
  end

end