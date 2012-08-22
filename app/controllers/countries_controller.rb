# The CountriesController provides actions to retrieve country data
# as JSON.
class CountriesController < ApplicationController
  skip_before_filter :authorize, only: [:by_area]

  respond_to :json

  # Sends a JSON containing the all countries grouped by area.
  def by_area
    respond_with Country.grouped_by_area
  end
end
