# The CvsController provides actions to upload/download and destroy Cvs.
class CvsController < ApplicationController
  skip_before_filter :authorize, only: [:show]

  # Checks, if the user has access to the experts section.
  def authorize
    super(:experts, expert_url(params[:expert_id]))
  end

  # Sends the stored Cv document.
  def show
    cv = Cv.includes(:expert).find(params[:id])
    send_file cv.absolute_path.to_s, filename: cv.public_filename
  end

  # Creates a new Cv by storing an uploaded file and loading its content
  # into the database.
  def create
    expert = Expert.find(params[:expert_id])
    cv = Cv.from_upload(params[:cv])

    unless (expert.cvs << cv)
      cv.destroy
      raise 'Could not save CV.'
    end

    flash[:notice] = t('messages.cv.success.store')
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('messages.expert.errors.find')
  rescue
    flash[:alert] = t('messages.cv.errors.store')
  ensure
    redirect_to(expert ? documents_expert_url(expert) : experts_url)
  end

  # Destroys a Cv.
  def destroy
    if Cv.find(params[:id]).destroy
      flash[:notice] = t('messages.cv.success.delete')
    else
      flash[:alert] = t('messages.cv.errors.delete')
    end

    redirect_to documents_expert_url(id: params[:expert_id])
  end

  private

  # Sets an alert flash and redirect to the experts detail page.
  def not_found
    flash[:alert] = t('messages.cv.errors.find')
    redirect_to documents_expert_url(params[:expert_id])
  end

  # Sets a proper redirect url.
  def file_not_found
    super(documents_expert_path(params[:expert_id]))
  end
end
