# The ContactsController provides all actions needed to add/remove contacts
# to/from a associated model.
class ContactsController < ApplicationController

  polymorphic_parent :experts, :partners

  # Checks the users privileges.
  def authorize
    super(parent[:controller], parent_url)
  end

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
  def create
    model = parent[:model].find(parent[:id])
    field, contact = params[:contact].values_at(:field, :contact)
    contact.strip!

    if contact.blank? || model.contact.field(field).include?(contact)
      raise 'I am not going to save blanks or duplicates!'
    end

    model.contact.field(field) << contact

    unless model.contact.save
      raise 'Could not save contact.'
    end

    flash[:notice] = t('messages.contact.success.save')
    redirect_to parent_url
  rescue ActiveRecord::RecordNotFound
    parent_not_found
  rescue
    flash[:alert] = t('messages.contact.errors.save')
    redirect_to parent_url
  end

  # Removes a contact from a field. It behaves like
  # ContactsController#add_to(), but vice versa.
  def destroy
    model = parent[:model].find(parent[:id])
    field, contact = params.values_at(:field, :contact)

    unless model.contact.field(field).delete(contact) && model.contact.save
      raise 'Could not delete contact.'
    end

    flash[:notice] = t('messages.contact.success.delete')
    redirect_to parent_url
  rescue ActiveRecord::RecordNotFound
    parent_not_found
  rescue
    flash[:alert] = t('messages.contact.errors.delete')
    redirect_to parent_url
  end

  private

  # Sets a flash message and redirects the user.
  def parent_not_found
    flash[:alert] = t(:"messages.#{parent[:model].to_s.downcase}.errors.find")
    redirect_to parents_url
  end
end
