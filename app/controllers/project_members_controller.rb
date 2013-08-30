#
class ProjectMembersController < ApplicationController
  before_filter :find_project, only: [:index, :create, :update, :destroy]

  skip_before_filter :authorize, only: [:index]

  # GET /projects/:project_id/members
  def index
    @info = @project.info
    @title = @info.title
  end

  # POST /projects/:project_id/members
  def create
    if @project.members.create(params[:project_member])
      flash[:notice] = t('messages.project_member.success.create')
    else
      flash[:alert] = t('messages.project_member.errors.create')
    end

    redirect_to project_members_path(@project)
  end

  # PUT /projects/:project_id/project_members/:id
  def update
    member = @project.members.find(params[:id])

    if member.update_attributes(params[:project_member])
      flash[:notice] = t('messages.project_member.success.save')
    else
      flash[:alert] = t('messages.project_member.errors.save')
    end

    redirect_to project_members_path(@project)
  end

  # DELETE /projects/:project_id/members/:id
  def destroy
    if @project.members.destroy(params[:id])
      flash[:notice] = t('messages.project_member.success.delete')
    else
      flash[:alert] = t('messages.project_member.errors.delete')
    end

    redirect_to project_members_path(@project)
  end

  private

  # Checks the users authorization.
  def authorize
    super(:projects, projects_url)
  end

  # Finds the project.
  def find_project
    @project = Project.find(params[:project_id])
  end
end
