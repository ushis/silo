# The ApplicationController handles authentication and provides generic
# methods, used by several other controllers. All controllers extend the
# ApplicationController.
class ApplicationController < ActionController::Base
  rescue_from UnauthorizedError,                   with: :unauthorized
  rescue_from ActiveRecord::RecordNotFound,        with: :not_found
  rescue_from ActionController::MissingFile,       with: :file_not_found
  rescue_from ActionController::RedirectBackError, with: :go_home

  protect_from_forgery

  before_filter :authenticate
  before_filter :authorize
  before_filter :set_locale

  helper_method :body_class
  helper_method :arrayified_param
  helper_method :current_list
  helper_method :current_user
  helper_method :current_user?

  # Appends a proper cache_path to all ActiveSupport::Concern.caches_action
  # calls.
  def self.caches_action(*actions)
    super *actions, cache_path: lambda { |_| action_cache_path }
  end

  private

  # Sets an error message and redirects the the root url.
  def unauthorized(url = root_url)
    flash[:alert] = t('messages.generics.errors.access')
    redirect_to url
  end

  # Sets a not found alert and redirects to the root url.
  def not_found
    flash[:alert] = t('messages.generics.errors.find')
    redirect_to root_url
  end

  # Sets a file not found alert and redirects to the root url.
  def file_not_found(url = root_url)
    flash[:alert] = t('messages.generics.errors.file_not_found')
    redirect_to url
  end

  # Redirects the user to the root url.
  def go_home
    redirect_to root_url
  end

  # Checks the users password and redirects her back, if it fails. It is
  # itended to be used as confirmation tool:
  #
  # "Are your sure? Please confirm with your password."
  #
  # Use it as a before filter.
  def check_password
    unless current_user.authenticate(params[:password])
      flash[:alert] = t('messages.user.errors.password')
      redirect_to :back
    end
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
      unauthorized(url)
    end
  end

  # Redirects the user to the login, unless he/she is already logged in.
  def authenticate
    redirect_to login_url unless current_user
  end

  # Returns cache a path for a actions view, dependent on current controller,
  # action and locale.
  def action_cache_path
    I18n.locale.to_s << request.path
  end

  # Sends a report to the browser.
  def send_report(report)
    send_data report.render,
              filename: "report-#{report.title.parameterize}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end

  # Sends a csv to the browser.
  def send_csv(csv, title)
    send_data csv, filename: "#{title.parameterize}.csv", type: 'text/csv'
  end

  # Returns a hash of arrayified params.
  #
  #   params[:some_ids]             #=> '123 423 65 34'
  #   arrayified_params(:some_ids)  #=> {some_ids: [123, 423, 65, 34]}
  #
  # This is useful in combination with params.merge to arrayify special keys.
  def arrayified_params(*keys)
    keys.inject({}) do |hsh, key|
      hsh[key] = arrayified_param(key)
      hsh
    end
  end

  # Returns an arrayified parameter.
  #
  #   params[:some_ids]            #=> '23 34 546'
  #   arrayified_param(:some_ids)  #=> [23, 34, 546]
  #
  # Returns an Array in any case.
  def arrayified_param(key)
    case (value = params[key])
    when Array then value
    when Hash then value.values
    else value.to_s.split
    end
  end

  # Returns the body class Array. It is prepopulated with the current
  # controller, action and the :admin class if the current user is an
  # admin. New classes can be added with ease:
  #
  #   body_class << :special
  #   #=> [:users, :edit, :admin, :special]
  #
  # In the layout:
  #
  #   <body class="<%= body_class.join(' ') %>">
  #
  # Returns an Array.
  def body_class
    @body_class ||= begin
      body_class = params.values_at(:controller, :action)
      body_class << :admin if current_user.try(:admin?)
      body_class
    end
  end

  # Returns the current list of the current user.
  def current_list
    current_user.try(:current_list)
  end

  # Checks if a user is the current user. Returns true if the user is the
  # current user, else false.
  def current_user?(user)
    user == current_user
  end

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
