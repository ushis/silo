# The HelpController serves help views. It is intended that they were loaded
# via AJAX, so they were not rendered within a layout.
#
# To add a new help section create the view
# _app/views/help/my_section.html.erb_. You can vistit it at
# _/help/my_section_.
class HelpController < ApplicationController
  skip_before_filter :authorize

  layout false

  # Serves a help section.
  def show
    render params[:section]
  rescue ActionView::MissingTemplate
    raise ActionController::RoutingError, 'Help not found.'
  end
end
