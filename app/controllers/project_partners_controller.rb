#
class ProjectPartnersController < ApplicationController
  before_filter :find_project, only: [:index, :create, :destroy]
  before_filter :find_partner, only: [:create, :destroy]

  skip_before_filter :authorize, only: [:index]

  # GET /projects/:project_id/partners
  def index
    @title = @project.info.try(:title)
  end

  # POST /projects/:project_id/partners
  def create
    if @project.add_partner(@partner)
      flash[:notice] = t('messages.project.success.add_partner', name: @partner.to_s)
    else
      flash[:alert] = t('messages.project.errors.add_partner')
    end

    redirect_to project_partners_url(@project)
  end

  # DELETE /projects/:project_id/partners/:id
  def destroy
    if @project.partners.destroy(@partner)
      flash[:notice] = t('messages.project.success.remove_partner', name: @partner.to_s)
    else
      flash[:alert] = t('messages.project.errors.remove_partner')
    end

    redirect_to project_partners_url(@project)
  end

  private

  # Checks the users privileges.
  def authorize
    super(:projects, projects_url)
  end

  # Finds the project.
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('messages.project.errors.find')
    redirect_to projects_url
  end

  # Finds the partner.
  def find_partner
    @partner = Partner.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('messages.partner.errors.find')
    redirect_to project_partners_url(@project)
  end
end
