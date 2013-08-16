#
class ProjectsController < ApplicationController
  skip_before_filter :authorize, only: [:index, :show]

  #
  def authorize
    super(:projects, projects_url)
  end

  #
  def index
    @title = t('labels.projects.all')
  end

  #
  def not_found
    flash[:alert] = t('messages.projects.errors.find')
    redirect_to projects_url
  end
end
