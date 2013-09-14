class Ajax::ProjectMembersController < Ajax::ApplicationController
  before_filter :authorize,              only: [:update]
  before_filter :find_project,           only: [:index, :search, :new, :update]
  before_filter :find_member,            only: [:update]
  before_filter :find_potential_expert,  only: [:new]
  before_filter :find_potential_experts, only: [:index, :search]

  respond_to :html, only: [:index, :search]
  respond_to :json, only: [:update]

  # GET /ajax/projects/:project_id/project_members
  def index
    # implicit render(:index)
  end

  # GET /ajax/projects/:project_id/project_members/search
  def search
    # implicit render(:search)
  end

  # GET /ajax/projects/:project_id/project_members/new/:expert_id
  def new
    @member = @expert.project_members.build
    @url = { controller: '/project_members', action: :create }
    render(:form)
  end

  # PUT /ajax/projects/:project_id/project_members/:id
  def update
    if @member.update_attributes(params[:project_member])
      render json: @member
    else
      error(t('messages.project_member.errors.save'))
    end
  end

  private

  # Checks the users authorization.
  def authorize
    super(:projects)
  end

  # Finds the project.
  def find_project
    @project = Project.find(params[:project_id])
  end

  # Finds the member.
  def find_member
    @member = @project.members.find(params[:id])
  end

  # Finds the potential expert
  def find_potential_expert
    @expert = @project.potential_experts.find(params[:expert_id])
  end

  # Finds potential experts.
  def find_potential_experts
    @experts = @project.potential_experts.search(params).limit(10)
  end
end
