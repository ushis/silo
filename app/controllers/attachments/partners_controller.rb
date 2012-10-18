# The Attachments::PartnersController provides actions to add/remove
# attachments to/from an Partner model. The real stuff happens in the
# AttachmentsController.
class Attachments::PartnersController < AttachmentsController

  # Checks, if the user has access to the _partners_ section.
  def authorize
    super(:partners, partners_url)
  end

  # Adds an uploaded attachment to a Partner.
  def create
    partner = Partner.find(params[:partner_id])
    add_to partner, documents_partner_url(partner)
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('messages.partner.errors.find')
    redirect_to partners_url
  end

  # Destroys an Attachment and redirects the user to the experts documents
  # pages.
  def destroy
    super
    redirect_to documents_partner_url(id: params[:partner_id])
  end

  # Sets a not found flash message and redirects the user.
  def not_found
    super(partners_url)
  end
end
