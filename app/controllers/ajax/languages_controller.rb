# The Ajax::LanguagesController provides several actions to retrieve
# language views via Ajax.
class Ajax::LanguagesController < AjaxController
  caches_action :index

  # Serves a multi select box.
  def index
    @languages = Language.ordered
    respond_with(@languages)
  end
end
