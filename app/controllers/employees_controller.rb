#
class EmployeesController < ApplicationController
  skip_before_filter :authorize, only: [:index]

  #
  def authorize
    super(:partners, partners_url)
  end

  #
  def index
    @partner = Partner.find(params[:partner_id])
    @title = t('labels.employees.all')
    body_class.delete('index')
  end

end
