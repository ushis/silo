# The Ajax::BusinessController provides helpers to access existing businesses.
# They should be used to help the user by filling out forms with widgets such
# as autocompletion or multiselect boxes.
class Ajax::BusinessesController < AjaxController
  caches_action :index

  # Serves all businesses in a multiselect box or as JSON.
  def index
    @businesses = Business.order(:business)
    respond_with(@businesses)
  end
end
