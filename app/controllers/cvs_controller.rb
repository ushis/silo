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
    send_file cv.absolute_path, filename: cv.public_filename
  end

  # Creates a new Cv by storing an uploaded file and loading it's content
  # into the database.
  def create
    begin
      expert = Expert.find(params[:expert_id])
    rescue
      flash[:alert] = t('messages.expert.errors.find')
      redirect_to experts_url and return
    end

    data = params[:cv]

    unless (cv = Cv.from_file(data[:file], data[:language_id]))
      flash[:alert] = t('messages.cv.errors.store')
      redirect_to document_expert_url(expert) and return
    end

    expert.cvs << cv
    flash[:notice] = t('messages.cv.success.store')
  rescue
    flash[:alert] = t('messages.cv.errors.store')
  ensure
    redirect_to documents_expert_url(expert)
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

  # Sets an alert flash and redirect to the experts detail page.
  def not_found
    flash[:alert] = t('messages.cv.errors.find')
    redirect_to documents_expert_url(params[:expert_id])
  end
end
