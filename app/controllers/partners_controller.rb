#
class PartnersController < ApplicationController

  before_filter :authorize, except: [:index, :show]

  #
  def authorize
    unless current_user.access?(:partners)
      flash[:alert] = t('msg.access_denied')
      redirect_to partners_url
    end
  end

  #
  def index
    @title = t('label.partners')
  end

  #
  def not_found
    flash[:alert] = t('msg.partner_not_found')
    refirect_to partners_url
  end
end
