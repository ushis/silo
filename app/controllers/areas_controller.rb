class AreasController < ApplicationController
  skip_before_filter :authorize, only: [:select]

  layout false

  def select
    @areas = Area.all
  end
end
