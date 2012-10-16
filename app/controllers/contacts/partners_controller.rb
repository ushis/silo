# The Contacts::PartnersController provides actions to add/delete contacts
# to/from an Partner model. This controller is not very smart, it just calls
# methods from the ContactsController, where the real stuff happens.
class Contacts::PartnersController < ContactsController

  # Checks, if the user has access to the _partners_ section.
  def authorize
    super(:partners, partners_url)
  end

  # Adds a contact to an Partner.
  def create
    partner = Partner.includes(:contact).find(params[:partner_id])
    add_to partner, partner_url(partner)
  end

  # Destroys one of the partners contacts.
  def destroy
    partner = Partner.includes(:contact).find(params[:partner_id])
    remove_from partner, partner_url(partner)
  end

  # Sets a flash message and redirects the user.
  def not_found
    flash[:alert] = t('messages.partner.errors.find')
    redirect_to partners_url
  end
end
