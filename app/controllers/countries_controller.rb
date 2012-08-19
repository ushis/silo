#
class CountriesController < ApplicationController
  skip_before_filter :authenticate, only: [:by_continent]
  skip_before_filter :authorize,    only: [:by_continent]

  respond_to :json

  def by_continent
    respond_with Country.ordered_by_continent
  end
end
