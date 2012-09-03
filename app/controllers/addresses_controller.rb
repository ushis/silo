# The AddressesController is the parent controller of all controllers in the
# Addresses module. It provides generic methods to manipulate the polymorphic
# Address model.
class AddressesController < ApplicationController

  protected

  # Adds a new address to a model and redirects the user to a url. It is
  # expected that the _params_ hash contains another info hash accessible
  # through the _:address_ key.
  def add_to(model, url)
    unless (model.addresses << Address.new(params[:address]))
      raise 'Could not save address.'
    end

    flash[:notice] = t('messages.address.success.save')
  rescue
    flash[:alert] = t('messages.address.errors.save')
  ensure
    redirect_to url
  end

  # Destroys an Address.
  def destroy
    if Address.find(params[:id]).destroy
      flash[:notice] = t('messages.address.success.delete')
    else
      flash[:alert] = t('messages.address.errors.delete')
    end
  end

  # Sets a flash message and redirect the user.
  def not_found(url = root_url)
    flash[:alert] = t('messages.address.errors.find')
    redirect_to url
  end
end
