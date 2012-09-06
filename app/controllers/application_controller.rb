# The ApplicationController handles authentication and provides generic
# methods, used by several other controllers. All controllers extend the
# ApplicationController.
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound,  with: :not_found
  rescue_from ActionController::MissingFile, with: :file_not_found

  protect_from_forgery

  before_filter :authenticate
  before_filter :authorize
  before_filter :set_locale
  before_filter :body_class

  helper_method :current_user
  helper_method :current_user?

  # Appends a proper cache_path to all ActiveSupport::Concern.caches_action
  # calls.
  def self.caches_action(*actions)
    super *actions, cache_path: lambda { |_| action_cache_path }
  end

  # Sets a not found alert and redirects to the root url.
  def not_found
    flash[:alert] = t('messages.generics.errors.find')
    redirect_to root_url
  end

  # Sets a file not found alert and redirects to the root url.
  def file_not_found
    flash[:alert] = t('messages.generics.errors.file_not_found')
    redirect_to root_url
  end

  # Returns cache a path for a actions view, dependent on current controller,
  # action and locale.
  def action_cache_path
    [I18n.locale, params[:controller], params[:action]].join('/')
  end

  # Ensures that the specified parameters are Arrays.
  def arrayify_params(*keys)
    keys.each do |key|
      unless params[key].is_a? Array
        params[key] = params[key].to_s.split(/\s+/)
      end
    end
  end

  # Inits the body class array and populates it with current controller,
  # action and wether the user is admin or not.
  def body_class
    @body_class = [params[:controller], params[:action]]
    @body_class << :admin if current_user.try(:admin?)
  end

  # Sets the users preferred locale.
  def set_locale
    I18n.locale = current_user.try(:locale) || locale_from_header
  end

  # Authorizes the user (or not) to complete a request. If the the user has
  # not the corresponding permissions, a flash message is set and the user
  # is redirected.
  def authorize(section = nil, url = root_url)
    unless (section ? current_user.access?(section) : current_user.admin?)
      flash[:alert] = t('messages.generics.errors.access')
      redirect_to url
    end
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

  # Extracts the preferred locale from the ACCEPT-LANGUAGE header.
  def locale_from_header
    request.env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(/^[a-z]{2}/).first
  end
end
