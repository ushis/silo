# The LanguagesController provides actions to retrieve language data as JSON.
class LanguagesController < ApplicationController
  skip_before_filter :authorize, only: [:select]

  layout false

  # Sends a JSON containing all languages ordered by language name.
  def select
    @languages = Language.ordered
  end
end
