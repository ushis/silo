# The Ajax::ContactsController handles Contact specific AJAX requests.
class Ajax::ContactsController < AjaxController
  respond_to :html, only: [:new]

  caches_action :new

  # Serves an empty contacts form.
  def new
    @url = { controller: '/contacts', action: :create }
  end
end
