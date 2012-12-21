# The ContactsController provides all actions needed to add/remove contacts
# to/from a associated model.
class ContactsController < ApplicationController
  before_filter :find_parent, only: [:create, :destroy]

  polymorphic_parent :experts, :employees

  # Adds a contact to a model, that has a _has_one_ association to the Contact
  # model. It uses the _params_ hash to determine the contact field and the
  # contact value.
  #
  # It is expected that the params hash includes both fields
  #
  #    params[:contact][:field]    # Fieldname, such as :emails or :phones
  #    params[:contact][:contact]  # Value, such as 'hello@aol.com'
  #
  # The user is redirected to the parents show page.
  #
  # POST /parents/:parent_id/contacts
  def create
    field, contact = params[:contact].try(:values_at, :field, :contact)

    if @parent.contact.add!(field, contact)
      flash[:notice] = t('messages.contact.success.save')
    else
      flash[:alert] = t('messages.contact.errors.save')
    end

    redirect_to :back
  end

  # Removes a contact from a field. It behaves like
  # ContactsController#add_to(), but vice versa.
  #
  # DELETE /parents/:parent_id/contacts/:id
  def destroy
    field, contact = params.values_at(:field, :contact)

    if @parent.contact.remove!(field, contact)
      flash[:notice] = t('messages.contact.success.delete')
    else
      flash[:alert] = t('messages.contact.errors.delete')
    end

    redirect_to(:back)
  end

  private

  # Checks the users privileges.
  def authorize
    super(parent[:controller], :back)
  end
end
