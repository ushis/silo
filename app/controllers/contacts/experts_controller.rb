# The Contacts::ExpertsController provides actions to add/delete contacts
# to/from an Expert model. This controller is not very smart, it just calls
# methods from the ContactsController, where the real stuff happens.
class Contacts::ExpertsController < ContactsController

  # Checks, if the user has access to the _experts_ section.
  def authorize
    super(:experts, experts_url)
  end

  # Adds a contact to an Expert.
  def create
    expert = Expert.includes(:contact).find(params[:expert_id])
    add_to expert, expert_url(expert)
  end

  # Destroys one of the experts contacts.
  def destroy
    expert = Expert.includes(:contact).find(params[:expert_id])
    remove_from expert, expert_url(expert)
  end

  # Sets a flash message and redirects the user.
  def not_found
    flash[:alert] = t('messages.expert.errors.find')
    redirect_to experts_url
  end
end
