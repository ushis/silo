# The Addresses::ExpertsController provides actions to add/remove addresses
# from/to Exoert models. The real stuff happens in the AddressesController.
class Addresses::ExpertsController < AddressesController

  # Checks if the user has access to the _experts_section_.
  def authorize
    super(:experts, experts_url)
  end

  # Creates a new Address and adds to an Expert.
  def create
    expert = Expert.includes(:addresses).find(params[:expert_id])
    add_to expert, expert_url(expert)
  end

  # Destroys an Address.
  def destroy
    super
    redirect_to expert_url(id: params[:expert_id])
  end

  # Sets a flash message and redirects the user.
  def not_found
    super(experts_url)
  end
end
