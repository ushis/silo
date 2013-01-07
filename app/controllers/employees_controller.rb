# Handles Employee specific requests.
class EmployeesController < ApplicationController
  before_filter :find_partner,  only: [:index, :create, :update, :destroy]
  before_filter :find_employee, only: [:update, :destroy]

  skip_before_filter :authorize, only: [:index]

  cache_sweeper :employee_sweeper, only: [:update, :destroy]

  # Serves a list of the partners employees.
  #
  # GET /partners/:partner_id/employees
  def index
    @title = t('labels.employee.all')
    body_class.delete('index')
  end

  # Adds an employee to the partner.
  #
  # POST /partners/:partner_id/employees
  def create
    employee = @partner.employees.build(params[:employee])

    if employee.save
      flash[:notice] = t('messages.employee.success.create', name: employee.name)
    else
      flash[:alter] = t('messages.employee.errors.create')
    end

    redirect_to partner_employees_url(@partner)
  end

  # Updates the employees attributes.
  #
  # PUT /partners/:partner_id/employees/:id
  def update
    if @employee.update_attributes(params[:employee])
      flash[:notice] = t('messages.employee.success.save')
    else
      flash[:alert] = t('messages.employee.errors.save')
    end

    redirect_to partner_employees_url(@partner)
  end

  # Deletes the employee.
  #
  # DELETE /partners/:partner_id/employees/:id
  def destroy
    if @employee.destroy
      flash[:notice] = t('messages.employee.success.delete', name: @employee.name)
    else
      flash[:alter] = t('messages.employee.errors.delete')
    end

    redirect_to partner_employees_url(@partner)
  end

  private

  # Checks the users permissions.
  def authorize
    super(:partners, partners_url)
  end

  # Finds the employees partner.
  def find_partner
    @partner = Partner.find(params[:partner_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('messages.partner.errors.find')
    redirect_to partners_url
  end

  # Finds the employee.
  def find_employee
    @employee = @partner.employees.find(params[:id])
  end

  # Sets an error message and redirects the user to the partners employees page.
  def not_found
    flash[:alert] = t('messages.employee.errors.find')
    redirect_to partner_employees_url(params[:partner_id])
  end
end
