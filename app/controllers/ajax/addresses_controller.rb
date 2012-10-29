# The Ajax::AddressesController handles Address specific AJAX requests.
class Ajax::AddressesController < AjaxController
  respond_to :html, only: [:new]

  caches_action :new

  # Serves an empty address form.
  def new
    @address = Address.new
    @url = { controller: '/addresses', action: :create }
  end
end
