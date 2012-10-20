# The AddressesController is the parent controller of all controllers in the
# Addresses module. It provides generic methods to manipulate the polymorphic
# Address model.
class AddressesController < ApplicationController

  polymorphic_parent :experts

  def authorize
    super(parent[:controller], parent_url)
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

    redirect_to parent_url
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t(:"messages.#{parent[:model].to_s.downcase}.errors.find")
    redirect_to partners_url
  end

  # Destroys an Address.
  def destroy
    address = Address.find(params[:id])

    if address.addressable_type != parent[:model].to_s
      flash[:alert] = t('messages.generics.errors.access')
      redirect_to parent_url and return
    end

    if address.destroy
      flash[:notice] = t('messages.address.success.delete')
    else
      flash[:alert] = t('messages.address.errors.delete')
    end

    redirect_to parent_url
  end

  private

  # Sets a flash message and redirect the user.
  def not_found(url = root_url)
    flash[:alert] = t('messages.address.errors.find')
    redirect_to parent_url
  end
end
