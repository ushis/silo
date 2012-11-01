# Handles Employee specific requests.
class EmployeesController < ApplicationController
  skip_before_filter :authorize, only: [:index]

  cache_sweeper :employee_sweeper, only: [:update, :destroy]

  # Checks the users permissions.
  def authorize
    super(:partners, partners_url)
  end

  # Serves a list of the partners employees.
  #
  # GET /partners/:partner_id/employees
  def index
    @partner = Partner.find(params[:partner_id])
    @title = t('labels.employee.all')
    body_class.delete('index')
  end

  # Adds an employee to the partner.
  #
  # POST /partners/:partner_id/employees
  def create
    partner = Partner.find(params[:partner_id])
    employee = Employee.new(params[:employee])

    if (partner.employees << employee)
      flash[:notice] = t('messages.employee.success.create', name: employee.name)
    else
      flash[:alter] = t('messages.employee.errors.create')
    end

    redirect_to partner_employees_url(partner)
  end

  # Updates the employees attributes.
  #
  # PUT /partners/:partner_id/employees/:id
  def update
    employee = Employee.find(params[:id])

    if employee.update_attributes(params[:employee])
      flash[:notice] = t('messages.employee.success.save')
    else
      flash[:alert] = t('messages.employee.errors.save')
    end

    redirect_to partner_employees_url(params[:partner_id])
  end

  # Deletes the employee.
  #
  # DELETE /partners/:partner_id/employees/:id
  def destroy
    employee = Employee.find(params[:id])

    if employee.destroy
      flash[:notice] = t('messages.employee.success.delete', name: employee.name)
    else
      flash[:alter] = t('messages.employee.errors.delete')
    end

    redirect_to partner_employees_url(params[:partner_id])
  end

  private

  # Sets an error message and redirects the user.
  def not_found
    flash[:alert] = t('messages.employee.errors.find')
    redirect_to partner_employees_url(params[:partner_id])
  end
end
