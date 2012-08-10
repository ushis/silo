# The AddressesController is the parent controller of all controllers in the
# Addresses module. It provides generic methods to manipulate the polymorphic
# Address model.
class AddressesController < ApplicationController

  protected

  # Adds a new address to a model and redirects the user to a url. It is
  # expected that the _params_ hash contains another info hash accessible
  # through the _:address_ key.
  def add_to(model, url)
    model.addresses << Address.new(params[:address])
    flash[:notice] = t('msg.saved_address.')
  rescue
    flash[:alert] = t('msg.could_not_save_address')
  ensure
    redirect_to url
  end

  # Destroys an Address.
  def destroy
    a = Address.find(params[:id])

    if a.destroy
      flash[:notice] = t('msg.deleted_address')
    else
      flash[:alert] = t('msf.could_not_delete_address')
    end
  end
end
