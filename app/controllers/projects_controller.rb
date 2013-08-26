#
class ProjectsController < ApplicationController
  before_filter :check_password, only: [:destroy]

  skip_before_filter :authorize, only: [:index, :show]

  #
  def authorize
    super(:projects, projects_url)
  end

  # GET /projects
  def index
    @title = t('labels.project.all')
    @projects = Project.ordered.includes(:infos).page(params[:page])
  end

  # GET /projects/:id
  def show
    @info = ProjectInfo.find(params[:id])
    @title = @info.title
  end

  # GET /projects/new
  def new
    @info = ProjectInfo.new
    @info.project = Project.new
    render_form(:new)
  end

  # POST /projects/:id
  def create
  end

  # GET /projects/:id/edit
  def edit
    @info = ProjectInfo.find(params[:id])
    render_form(:edit)
  end

  # PUT /projects/:id
  def update
  end

  # DELETE /projects/:id
  def destroy
    project = Project.find(params[:id])
    info = project.info

    if project.destroy
      flash[:notice] = t('messages.project.success.delete', info.try(:title))
      redirect_to projects_url
    else
      flash[:alert] = t('messages.project.errors.delete')
      redirect_to project_url(info)
    end
  end

  private

  # Renders the projects form.
  def render_form(action)
    body_class << action
    @title = ("labels.action.#{action}")
    render :form
  end

  # Sets an error message and redirects the user.
  def not_found
    flash[:alert] = t('messages.project.errors.find')
    redirect_to projects_url
  end
end
