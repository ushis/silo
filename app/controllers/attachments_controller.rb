# The AttachmentsController provides the ability to serve, create and destroy
# all attachments.
class AttachmentsController < ApplicationController
  skip_before_filter :authorize, only: [:show]

  polymorphic_parent :experts, :partners

  # Checks if the user is authorized and redirects if not.
  def authorize
    super(parent[:controller], parents_url)
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

    unless (model.attachments << attachment)
      attachment.destroy
      raise 'Could not save attachment.'
    end

    flash[:notice] = t('messages.attachment.success.store')
    redirect_to parent_url
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t(:"messages.#{parent[:model].to_s.downcase}.errors.find")
    redirect_to parents_url
  rescue
    flash[:alert] = t('messages.attachment.errors.store')
    redirect_to parent_url
  end

  # Destroys an attachment and redirects to the document page of the parent.
  def destroy
    attachment = Attachment.find(params[:id])

    if attachment.attachable_type != parent[:model].to_s
      flash[:alert] = t('messages.generics.errors.access')
      redirect_to parent_url and return
    end

    if attachment.destroy
      flash[:notice] = t('messages.attachment.success.delete')
    else
      flash[:alert] = t('messages.attachment.errors.delete')
    end

    redirect_to parent_url
  end

  private

  # Returns the url to the document page of the parent.
  def parent_url
    { controller: parent[:controller], action: :documents, id: parent[:id] }
  end

  # Sets a not found flash message and redirects the user.
  def not_found(url = root_url)
    flash[:alert] = t('messages.attachment.errors.find')
    redirect_to parent_url
  end
end
