# The AreasController is like the LanguagesController for areas/countries.
# All views were rendered without a layout.
class AreasController < ApplicationController
  skip_before_filter :authenticate, :authorize, only: [:select]

  layout false

  caches_action :select

  # Serves a multi select box for countries grouped by areas.
  def select
    @areas = Area.with_ordered_countries
  end
end
