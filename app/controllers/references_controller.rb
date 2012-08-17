#
class ReferencesController < ApplicationController
  skip_before_filter :authorize, only: [:index, :show]

  #
  def authorize
    super(:references, references_url)
  end

  #
  def index
    @title = t('labels.references.index')
  end

  #
  def not_found
    flash[:alert] = t('messages.reference.errors.find')
    refirect_to references_url
  end
end
