# The Ajax::AreasController is like the Ajax::LanguagesController for
# areas/countries.
class Ajax::AreasController < AjaxController
  caches_action :index

  # Serves a multi select box for countries grouped by areas.
  def index
    @areas = Area.with_ordered_countries
    respond_with(@areas)
  end
end
