# The ExpertsController provides basic CRUD actions for the experts data.
class ExpertsController < ApplicationController

  # Serves a paginated table of all experts.
  def index
    @title = t(:label_experts)
  end
end
