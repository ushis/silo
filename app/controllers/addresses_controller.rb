#
class AddressesController < ApplicationController

  protected

  def append_to(model, url)
    model.addresses << Address.new(params[:address])

    if model.save
      flash[:notice] = t('msg.saved_address')
    else
      raise 'Could not save address.'
    end
  rescue
    flash[:alert] = t('msg.could_not_save_address')
  ensure
    redirect_to url
  end

  def destroy
    a = Address.find(params[:id])

    if a.destroy
      flash[:notice] = t('msg.deleted_address')
    else
      flash[:alert] = t('msf.could_not_delete_address')
    end
  end
end
