# The AttachmentsController is the parent controller of all controllers
# in the Attachments module. It provides generic methods to manipulate the
# polymorphic Attachment model.
class AttachmentsController < ApplicationController
  skip_before_filter :authorize, only: [:show]

  # Sends the stored file to the user.
  def show
    a = Attachment.find(params[:id])
    send_file a.absolute_path, filename: a.public_filename
  end

  protected

  # Adds an uploaded attachment to a specified model. It is expected that the
  # model has a _has_many_ or a _has_and_belongs_to_many_ association to the
  # Attachment model.
  #
  # It is ensured that the user is redirected to the specified url.
  def add_to(model, url)
    a = Attachment.from_upload(params[:attachment])

    unless (model.attachments << a)
      a.destroy
      raise 'Could not save attachment.'
    end

    flash[:notice] = t('messages.attachment.success.store')
  rescue
    flash[:alert] = t('messages.attachment.errors.store')
  ensure
    redirect_to url
  end

  # Destroys an Attachment from database and file system.
  def destroy
    if Attachment.find(params[:id]).destroy
      flash[:notice] = t('messages.attachment.success.delete')
    else
      flash[:alert] = t('messages.attachment.errors.delete')
    end
  end

  # Sets a not found flash message and redirects the user.
  def not_found(url = root_url)
    flash[:alert] = t('messages.attachment.errors.find')
    redirect_to url
  end
end
