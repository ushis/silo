#
class HelpController < ApplicationController
  skip_before_filter :authorize

  layout false

  def show
    render params[:section]
  rescue
    raise ActionController::RoutingError, 'Help not found.'
  end
end
