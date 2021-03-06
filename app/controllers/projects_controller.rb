#
class ProjectsController < ApplicationController
  before_filter :check_password, only: [:destroy]
  before_filter :find_project,   only: [:show, :documents, :edit, :update, :destroy]

  skip_before_filter :authorize, only: [:index, :show]

  #
  def authorize
    super(:projects, projects_url)
  end

  # GET /projects(/page/:page)
  def index
    @title = t('labels.project.all')
    @projects = Project.includes(:infos).search(params).page(params[:page])
  end

  # GET /projects/:id(/:lang)
  def show
    if params.key?(:lang)
      @info = @project.info_by_language!(params[:lang])
    else
      @info = @project.info
    end

    @title = @info.title
  end

  # GET /projects/:id/documents
  def documents
    @info = @project.info
    @title = @info.try(:title)
  end

  # GET /projects/new
  def new
    @project = Project.new
    @info = ProjectInfo.new
    render_form(:new)
  end

  # POST /projects
  def create
    @project = current_user.projects.build(params[:project])
    @info = @project.infos.build(params[:project_info])

    if @info.save
      flash[:notice] = t('messages.project.success.create', title: @info.title)
      redirect_to project_url(@project, @info.language)
    else
      flash.now[:alert] = t('messages.project.errors.create')
      render_form(:new)
    end
  end

  # GET /projects/:id/edit/:lang
  def edit
    @info = @project.info_by_language(params[:lang])
    render_form(:edit)
  end

  # PUT /projects/:id/:lang
  def update
    @info = @project.info_by_language(params[:lang])
    @info.project.attributes = params[:project]
    @info.project.user = current_user

    if @info.update_attributes(params[:project_info])
      flash[:notice] = t('messages.project.success.save')
      redirect_to project_url(@project, @info.language)
    else
      flash.now[:alert] = t('messages.project.erros.save')
      render_form(:edit)
    end
  end

  # DELETE /projects/:id
  def destroy
    if @project.destroy
      flash[:notice] = t('messages.project.success.delete', title: @project.title)
      redirect_to projects_url
    else
      flash[:alert] = t('messages.project.errors.delete')
      redirect_to project_url(@project)
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
    @title = t("labels.project.#{action}")
    render :form
  end

  # Sets an error message and redirects the user.
  def not_found
    flash[:alert] = t('messages.project.errors.find')
    redirect_to projects_url
  end
end
