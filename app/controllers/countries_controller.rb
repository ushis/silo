# The CountriesController provides actions to retrieve country data
# as JSON.
class CountriesController < ApplicationController
  skip_before_filter :authenticate, only: [:by_continent]
  skip_before_filter :authorize,    only: [:by_continent]

  respond_to :json

  # Sends a JSON containing the all countries grouped by continent.
  def by_continent
    respond_with Country.grouped_by_continent
  end
end
