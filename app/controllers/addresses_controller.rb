# The AddressesController is the parent controller of all controllers in the
# Addresses module. It provides generic methods to manipulate the polymorphic
# Address model.
class AddressesController < ApplicationController
  polymorphic_parent :experts

  def authorize
    super(parent[:controller], :back)
  end

  # Adds a new address to a model and redirects the user to a url. It is
  # expected that the _params_ hash contains another info hash accessible
  # through the _:address_ key.
  def create
    model = parent[:model].find(parent[:id])

    if (model.addresses << Address.new(params[:address]))
      flash[:notice] = t('messages.address.success.save')
    else
      flash[:alert] = t('messages.address.errors.save')
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t(:"messages.#{parent[:model].to_s.downcase}.errors.find")
  ensure
    redirect_to :back
  end

  # Destroys an Address.
  def destroy
    address = Address.find(params[:id])

    if address.addressable_type != parent[:model].to_s
      unauthorized(:back) and return
    end

    if address.destroy
      flash[:notice] = t('messages.address.success.delete')
    else
      flash[:alert] = t('messages.address.errors.delete')
    end

    redirect_to :back
  end

  private

  # Sets a proper error message and redirects back.
  def not_found
    flash[:alert] = t('messages.address.errors.find')
    redirect_to :back
  end
end
