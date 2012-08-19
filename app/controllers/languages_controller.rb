# The LanguagesController provides actions to retrieve language data as JSON.
class LanguagesController < ApplicationController
  skip_before_filter :authenticate, only: [:index]
  skip_before_filter :athorize,     only: [:index]

  respond_to :json

  # Sends a JSON containing all languages ordered by language name.
  def index
    respond_with Language.select_box_friendly(:ordered)
  end
end
