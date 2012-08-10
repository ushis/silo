#
class PartnersController < ApplicationController
  skip_before_filter :authorize, only: [:index, :show]

  #
  def authorize
    super(:partners, partners_url)
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
