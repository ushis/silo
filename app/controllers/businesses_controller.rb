# The BusinessController provides helpers to access existing businesses. They
# should be used to help the user by filling out forms with widgets such as
# autocompletion or multiselect boxes.
class BusinessesController < ApplicationController
  skip_before_filter :authenticate, :authorize, only: [:select]

  layout false

  # Serves all businesses in a multiselect box or as JSON.
  def select
    @businesses = Business.order(:business)

    respond_to do |format|
      format.html
      format.json { render json: @businesses }
    end
  end
end
