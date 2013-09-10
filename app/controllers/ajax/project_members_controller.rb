class Ajax::ProjectMembersController < Ajax::ApplicationController
  respond_to :html, only: [:new, :edit]

  # GET /ajax/projects/:project_id/project_members/new
  def new
    @member = ProjectMember.new
    @url = { controller: '/project_members', action: :create }
    render(:form)
  end

  # GET /ajax/projects/:project_id/project_members/:id/edit
  def edit
    @member = Project.find(params[:project_id]).members.find(params[:id])
    @url = { controller: '/project_members', action: :update }
    render(:form)
  end
end
