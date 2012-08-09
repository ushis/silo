class AttachmentsController < ApplicationController
  before_filter :authorize, except: [:show]

  def show
    a = Attachment.find(params[:id])
    send_file a.absolute_path, filename: a.public_filename
  end

  protected

  def add_to(model, url)
    unless (a = Attachment.from_upload(params.fetch(:attachment)))
      flash[:alert] = t('msg.could_not_store_attachment')
      redirect_to url and return
    end

    model.attachments << a
    flash[:notice] = t('msg.stored_new_attachment')
  rescue
    flash[:alert] = t('msg.could_not_store_attachment')
  ensure
    redirect_to url
  end

  def destroy
    a = Attachment.find(params[:id])

    if a.destroy
      flash[:notice] = t('msg.deleted_attachment')
    else
      flash[:alert] = t('msg.could_not_delete_attachment')
    end
  end

  def not_found(url = root_url)
    flash[:alert] = t('msg.attachment_not_found')
    redirect_to url
  end
end
