# The LanguagesController provides several actions to retrieve language views
# via Ajax. They were not rendered within a layout.
class LanguagesController < ApplicationController
  skip_before_filter :authenticate, :authorize, only: [:select]

  layout false

  # Serves a multi select box.
  def select
    @languages = Language.ordered
  end
end
