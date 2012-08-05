#
class ReferencesController < ApplicationController

  before_filter :authorize, except: [:index, :show]

  #
  def authorize
    unless current_user.access?(:references)
      flash[:alert] = t('msg.access_denied')
      redirect_to references_url
    end
  end

  #
  def index
    @title = t('label.references')
  end

  #
  def not_found
    flash[:alert] = t('msg.reference_not_found')
    refirect_to references_url
  end
end
