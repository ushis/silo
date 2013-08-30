class Ajax::ProjectMembersController < Ajax::ApplicationController
  respond_to :html, only: [:new]

  caches_action :new

  # GET /ajax/projects/:project_id/project_members/new
  def new
    @member = ProjectMember.new
    @url = { controller: '/project_members', action: :create }
    render(:form)
  end
end
