# The AttachmentsController provides the ability to serve, create and destroy
# all attachments.
class AttachmentsController < ApplicationController
  skip_before_filter :authorize, only: [:show]

  polymorphic_parent :experts, :partners

  # Checks if the user is authorized and redirects if not.
  def authorize
    super(parent[:controller], :back)
  end

  # Sends the stored file to the user.
  def show
    a = Attachment.find(params[:id])
    send_file a.absolute_path, filename: a.public_filename
  end

  # Stores a new attachment and associates it with a parent model.
  def create
    model = parent[:model].find(parent[:id])
    attachment = Attachment.from_upload(params[:attachment])

    if (model.attachments << attachment)
      flash[:notice] = t('messages.attachment.success.store') and return
    end

    attachment.destroy
    flash[:alert] = t('messages.attachment.errors.store')
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t(:"messages.#{parent[:model].to_s.downcase}.errors.find")
  rescue
    flash[:alert] = t('messages.attachment.errors.store')
  ensure
    redirect_to :back
  end

  # Destroys an attachment and redirects to the document page of the parent.
  def destroy
    attachment = Attachment.find(params[:id])

    if attachment.attachable_type != parent[:model].to_s
      unauthorized(:back) and return
    end

    if attachment.destroy
      flash[:notice] = t('messages.attachment.success.delete')
    else
      flash[:alert] = t('messages.attachment.errors.delete')
    end

    redirect_to :back
  end

  private

  # Sets an error message an redirects back.
  def file_not_found
    super(:back)
  end

  # Sets an error message and redirects back.
  def not_found
    flash[:alert] = t('messages.attachment.errors.find')
    redirect_to :back
  end
end
