#
class Ajax::ProjectPartnersController < Ajax::ApplicationController
  respond_to :html, only: [:new]

  # GET /ajax/projects/:project_id/partners/new
  def new
    @url = { controller: '/project_partners', action: :create }
    render(:form)
  end
end
