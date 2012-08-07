# The ApplicationController handles authentication and provides generic
# methods, used by several other controllers. All controllers extend the
# ApplicationController.
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound,  with: :not_found
  rescue_from ActionController::MissingFile, with: :file_not_found

  protect_from_forgery

  before_filter :authenticate
  before_filter :set_locale
  before_filter :body_class

  helper_method :current_user
  helper_method :current_user?

  # Sets a not found alert and redirects to the root url.
  def not_found
    flash[:alert] = t('msg.record_not_found')
    redirect_to root_url
  end

  # Sets a file not found alert and redirects to the root url.
  def file_not_found
    flash[:alert] = t('msg.file_not_found')
    redirect_to root_url
  end

  # Inits the body class array and populates it with current controller,
  # action and wether the user is admin or not.
  def body_class
    @body_class = [params[:controller], params[:action]]
    @body_class << :admin if current_user.try(:admin?)
  end

  # Sets the users preffered locale.
  def set_locale
    I18n.locale = current_user.locale if current_user
  end

  # Redirects the user to the login, unless he/she is already logged in.
  def authenticate
    redirect_to login_url unless current_user
  end

  # Checks if a user is the current user. Returns true if the user is the
  # current user, else false.
  def current_user?(user)
    user == current_user
  end

  private

  # Returns the current user, if he/she is logged in.
  def current_user
    if session[:login_hash]
      @current_user ||= User.find_by_login_hash(session[:login_hash])
    end
  end
end
