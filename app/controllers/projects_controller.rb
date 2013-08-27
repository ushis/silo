#
class ProjectsController < ApplicationController
  before_filter :check_password, only: [:destroy]
  before_filter :find_project,   only: [:show, :edit, :update, :destroy]

  skip_before_filter :authorize, only: [:index, :show]

  #
  def authorize
    super(:projects, projects_url)
  end

  # GET /projects(/page/:page)
  def index
    @title = t('labels.project.all')
    @projects = Project.ordered.includes(:infos).page(params[:page])
  end

  # GET /projects/:id/:lang
  def show
    @info = @project.info_by_language!(params[:lang])
    @title = @info.title
  end

  # GET /projects/new/:lang
  def new
    @project = Project.new
    render_form(:new)
  end

  # POST /projects
  def create
  end

  # GET /projects/:id/edit/:lang
  def edit
    render_form(:edit)
  end

  # PUT /projects/:id
  def update
  end

  # DELETE /projects/:id
  def destroy
    info = @project.info

    if project.destroy
      flash[:notice] = t('messages.project.success.delete', info.try(:title))
      redirect_to projects_url
    else
      flash[:alert] = t('messages.project.errors.delete')
      redirect_to project_url(info)
    end
  end

  private

  # Finds the project.
  def find_project
    @project = Project.find(params[:id])
  end

  # Renders the projects form.
  def render_form(action)
    body_class << action
    @title = ("labels.action.#{action}")
    @info = @project.info_by_language(params[:lang])
    render :form
  end

  # Sets an error message and redirects the user.
  def not_found
    flash[:alert] = t('messages.project.errors.find')
    redirect_to projects_url
  end
end
