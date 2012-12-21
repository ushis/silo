# The AddressesController is the parent controller of all controllers in the
# Addresses module. It provides generic methods to manipulate the polymorphic
# Address model.
class AddressesController < ApplicationController
  before_filter :find_parent, only: [:create, :destroy]

  polymorphic_parent :experts

  # Adds a new address to a model and redirects the user to a url. It is
  # expected that the _params_ hash contains another info hash accessible
  # through the _:address_ key.
  #
  # POST /parents/:parent_id/addresses
  def create
    if (@parent.addresses << Address.new(params[:address]))
      flash[:notice] = t('messages.address.success.save')
    else
      flash[:alert] = t('messages.address.errors.save')
    end

    redirect_to :back
  end

  # Destroys an Address.
  #
  # DELETE /parents/:parent_id/addresses/:id
  def destroy
    if @parent.addresses.find(params[:id]).destroy
      flash[:notice] = t('messages.address.success.delete')
    else
      flash[:alert] = t('messages.address.errors.delete')
    end

    redirect_to :back
  end

  private

  # Checks the users permissions sends a redirect if necessary.
  def authorize
    super(parent[:controller], :back)
  end

  # Sets a proper error message and redirects back.
  def not_found
    flash[:alert] = t('messages.address.errors.find')
    redirect_to :back
  end
end
