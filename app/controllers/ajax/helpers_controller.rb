# The HelperController serves helper views. Such as generic confirm dialogs.
class Ajax::HelpersController < Ajax::ApplicationController
  caches_action :show

  # Serves a helper.
  def show
    render params[:id]
  rescue ActionView::MissingTemplate
    raise ActionController::RoutingError, 'Helper not found.'
  end
end
