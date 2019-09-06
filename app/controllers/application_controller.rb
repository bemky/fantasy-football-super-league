class ApplicationController < ActionController::Base

  before_action :set_root_url
  before_action :set_access_token

  def set_root_url
    Rails.application.config.root_url = root_url
  end
  
  def set_access_token
    
    start_time = Time.now
    if session[:access_token] && session[:access_token_expires_at] <= Time.now
      response = Yahoo.authenticate(refresh_token: session[:refresh_token])
      session[:access_token]             = response["access_token"]
      session[:access_token_expires_at]  = start_time + response["expires_in"] - 30
      session[:refresh_token]            = response["refresh_token"]
    end
    if params[:code]
      response = Yahoo.authenticate(code: params[:code])
      session[:access_token]             = response["access_token"]
      session[:access_token_expires_at]  = start_time + response["expires_in"] - 30
      session[:refresh_token]            = response["refresh_token"]
      redirect_to '/'
      return
    end
    
    return session[:access_token] if session[:access_token]
    
    redirect_to Yahoo.oauth_url
  end
  
  def index
    response = Yahoo.get('/league/390.l.1101180/standings', session[:access_token]);
    @data = Hash.from_xml(response)
    
  end
  
end
