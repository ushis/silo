#
class ContactsController < ApplicationController
  before_filter :authorize

  def authorize
    unless current_user.admin?
      t('msg.access_denied')
      redirect_to root_url
    end
  end

  protected

  def add_to(model, url)
    c = params[:contact]

    raise 'I am not going to save blank contacts!' if c[:contact].blank?

    model.contact.send(c[:field]) << c[:contact].strip

    if model.contact.save
      flash[:notice] = t('msg.saved_contact')
    else
      raise 'Could not save contact.'
    end
  rescue
    flash[:alert] = t('msg.could_not_save_contact')
  ensure
    redirect_to url
  end

  def remove_from(model, url)
    c = params[:contact]

    if model.contact.send(c[:field]).delete(c[:contact]) && model.contact.save
      flash[:notice] = t('msg.deleted_contact')
    else
      flash[:alert] = t('msg.could_not_delete_contact')
    end
  rescue
    flash[:alert] = t('msg.could_not_delete_contact')
  ensure
    redirect_to url
  end
end
