# The AttachmentsController provides the ability to serve, create and destroy
# all attachments.
class AttachmentsController < ApplicationController
  before_filter :find_parent, only: [:create, :destroy]

  skip_before_filter :authorize, only: [:show]

  polymorphic_parent :experts, :partners, :projects

  # Sends the stored file to the user.
  #
  # GET /parents/:parent_id/attachments/:id
  def show
    a = Attachment.find(params[:id])
    send_file a.absolute_path, filename: a.public_filename
  end

  # Stores a new attachment and associates it with a parent model.
  #
  # POST /parents/:parent_id/attachments
  def create
    if @parent.attachments.build(params[:attachment]).save_or_destroy
      flash[:notice] = t('messages.attachment.success.store')
    else
      flash[:alert] = t('messages.attachment.errors.store')
    end

    redirect_to :back
  end

  # Destroys an attachment and redirects to the document page of the parent.
  #
  # DELETE /parents/:parent_id/attachments/:id
  def destroy
    if @parent.attachments.find(params[:id]).destroy
      flash[:notice] = t('messages.attachment.success.delete')
    else
      flash[:alert] = t('messages.attachment.errors.delete')
    end

    redirect_to :back
  end

  private

  # Checks if the user is authorized and redirects if not.
  def authorize
    super(parent[:controller], :back)
  end

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
