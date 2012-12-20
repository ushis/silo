# The CvsController provides actions to upload/download and destroy Cvs.
class CvsController < ApplicationController
  before_filter :find_expert, only: [:create]

  skip_before_filter :authorize, only: [:show]

  # Sends the stored Cv document.
  #
  # GET /experts/:expert_id/cvs/:id
  def show
    cv = Cv.find(params[:id])
    send_file cv.absolute_path.to_s, filename: cv.public_filename
  end

  # Creates a new Cv by storing an uploaded file and loading its content
  # into the database.
  #
  # POST /experts/:expert_id/cvs
  def create
    if @expert.add_cv_from_upload(params[:cv])
      flash[:notice] = t('messages.cv.success.store')
    else
      flash[:alert] = t('messages.cv.errors.store')
    end

    redirect_to documents_expert_url(@expert)
  end

  # Destroys a Cv.
  #
  # DELETE /experts/:expert_id/cvs/:id
  def destroy
    if Cv.find(params[:id]).destroy
      flash[:notice] = t('messages.cv.success.delete')
    else
      flash[:alert] = t('messages.cv.errors.delete')
    end

    redirect_to documents_expert_url(id: params[:expert_id])
  end

  private

  # Checks, if the user has access to the experts section.
  def authorize
    super(:experts, expert_url(params[:expert_id]))
  end

  # Finds the expert
  def find_expert
    @expert = Expert.find(params[:expert_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('messages.expert.errors.find')
    redirect_to experts_url
  end

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
