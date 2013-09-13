#
class Ajax::ProjectPartnersController < Ajax::ApplicationController
  before_filter :find_project,            only: [:index, :search]
  before_filter :find_potential_partners, only: [:index, :search]

  respond_to :html, only: [:index, :search]

  # GET /ajax/projects/:project_id/partners
  def index
    # implicit render(:index)
  end

  # GET /ajax/projects/:project_id/partners/search
  def search
    # implicit render(:search)
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def find_potential_partners
    @partners = @project.potential_partners(params[:q]).ordered.limit(10)
  end
end
