# The ContactsController provides all actions needed to add/remove contacts
# to/from a associated model.
class ContactsController < ApplicationController
  polymorphic_parent :experts, :partners, :employees

  # Checks the users privileges.
  def authorize
    super(parent[:controller], :back)
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
    field, contact = params[:contact].try(:values_at, :field, :contact)
    contact.try(:strip!)

    if contact.blank? || model.contact.field(field).include?(contact)
      error(:save) and return
    end

    model.contact.field(field) << contact

    unless model.contact.save
      error(:save) and return
    end

    success(:save)
  rescue ArgumentError
    error(:save)
  ensure
    redirect_to(:back)
  end

  # Removes a contact from a field. It behaves like
  # ContactsController#add_to(), but vice versa.
  def destroy
    model = parent[:model].find(parent[:id])
    field, contact = params.values_at(:field, :contact)

    unless model.contact.field(field).delete(contact) && model.contact.save
      error(:delete) and return
    end

    success(:delete)
  rescue ArgumentError
    error(:delete)
  ensure
    redirect_to(:back)
  end

  private

  # Sets a success flash message.
  def success(action)
    flash[:notice] = t(action, scope: [:messages, :contact, :success])
  end

  # Sets an error flash message.
  def error(action)
    flash[:alert] = t(action, scope: [:messages, :contact, :errors])
  end

  # Sets a proper flash message.
  def not_found
    flash[:alert] = t(:"messages.#{parent[:model].to_s.downcase}.errors.find")
  end
end
