#
class CvsController < ApplicationController
  before_filter :authorize, except: [:show]

  #
  def authorize
    unless current_user.access?(:experts)
      flash[:alert] = t('msg.access_denied')
      redirect_to expert_url(params[:expert_id])
    end
  end

  #
  def show
    cv = Cv.includes(:expert).find(params[:id])
    send_file cv.absolute_path, filename: cv.public_filename
  end

  # Sets an alert flash and redirect to the experts detail page.
  def not_found
    flash[:alert] = t('msg.cv_not_found')
    redirect_to expert_url(params[:expert_id])
  end
end
