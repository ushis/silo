#
class PartnersController < ApplicationController
  skip_before_filter :authorize, only: [:index, :show]

  #
  def authorize
    super(:partners, partners_url)
  end

  #
  def index
    @title = t('labels.partners.index')
  end

  #
  def not_found
    flash[:alert] = t('messages.partner.errors.find')
    refirect_to partners_url
  end
end
