require 'dropbox_sdk'
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_path
  end
    ###########################################################################
  def unauthorize
    session[:dropbox_session] = nil
    current_user.dropbox_session = nil
    current_user.save!
  end

  def authorize
    dbsession = DropboxSession.new(ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_KEY_SECRET'])
    #serialize and save this DropboxSession
    session[:dropbox_session] = dbsession.serialize
    #pass to get_authorize_url a callback url that will return the user here
    redirect_to dbsession.get_authorize_url url_for(:action => 'dropbox_callback')
  end
 
# @Params : None
# @Return : None
# @Purpose : To callback for dropbox authorization
  def dropbox_callback
    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    dbsession.get_access_token #we've been authorized, so now request an access_token
    session[:dropbox_session] = dbsession.serialize
    
    current_user.update_attributes(:dropbox_session => session[:dropbox_session])
    session.delete :dropbox_session
    flash[:success] = "You have successfully authorized with dropbox."
    redirect_to current_user
  end # end of dropbox_callback action


end