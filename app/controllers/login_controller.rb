# The LoginController provides basic login/logout actions.
class LoginController < ApplicationController
  layout 'login'

  skip_before_filter :authenticate, only: [:welcome, :login]
  skip_before_filter :authorize,    only: [:welcome, :login, :logout]

  before_filter :forward, except: [:logout]

  # Forwards the user to the root url, if he/she is already logged in.
  def forward
    redirect_to root_url if current_user
  end

  # Serves a simple login form
  def welcome
    @title = t('labels.generic.welcome')
  end

  # Checks the users credentials and loggs he/she in, if they are correct.
  def login
    @title = t('labels.generic.welcome')
    @username = params[:username]
    user = User.find_by_username(@username)

    unless user.try(:authenticate, params[:password])
      flash.now[:alert] = t('messages.user.errors.credentials')
      render :welcome and return
    end

    unless user.refresh_login_hash!
      flash.now[:alert] = t('messages.generics.errors.error')
      render :welcome and return
    end

    session[:login_hash] = user.login_hash
    redirect_to root_url
  end

  # Loggs out the user and renders the login form.
  def logout
    @title = t('labels.generic.welcome')
    @username = current_user.username
    session[:login_hash] = nil
    render :welcome
  end
end
