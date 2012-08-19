#
class LanguagesController < ApplicationController
  skip_before_filter :authenticate, only: [:index]
  skip_before_filter :athorize,     only: [:index]

  respond_to :json

  def index
    respond_with Language.select_box_friendly(:ordered)
  end
end
