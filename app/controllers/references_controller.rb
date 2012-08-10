#
class ReferencesController < ApplicationController
  skip_before_filter :authorize, only: [:index, :show]

  #
  def authorize
    super(:references, references_url)
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
