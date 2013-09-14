# The Ajax::ApplicationController is the base of all controllers in the Ajax
# namespace. It provides special error handling and some tools to ensure a
# nice ajaxified day.
class Ajax::ApplicationController < ApplicationController
  before_filter :check_xhr

  skip_before_filter :authorize

  layout false

  respond_to :html, :json

  private

  # Renders an error message and sets the 401 status.
  def unauthorized
    error(t('messages.generics.errors.access'), 401)
  end

  # Renders an error message and sets the 404 status.
  def not_found(message = t('messages.generics.errors.find'))
    error(message, 404)
  end

  # Renders an error message and sets the 401, if the user is not logged in.
  def authenticate
    unauthorized unless current_user
  end

  # Renders an error message and sets the 401, if the user is not authorized.
  def authenticate(section = nil)
    unless (section ? current_user.access?(section) : current_user.admin?)
      unauthorized
    end
  end

  # Redirects the user the root url, if this is no ajax request.
  def check_xhr
    redirect_to(root_url) unless request.xhr? || Rails.env.development?
  end

  # Renders an error message and sets the response status code.
  def error(message, status = 422)
    render text: message, status: status
  end
end
