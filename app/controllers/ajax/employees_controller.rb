# Handles Employee specific AJAX requests.
class Ajax::EmployeesController < AjaxController
  respond_to :html, only: [:new, :edit]

  caches_action :new, :edit

  # Serves an empty employee form.
  #
  # GET /ajax/partners/:partner_id/employees/new
  def new
    @employee = Employee.new
    @url = { controller: '/employees', action: :create }
    render :form
  end

  # Serves an employee form.
  #
  # GET /ajax/partners/:partner_id/employees/:id/edit
  def edit
    @employee = Employee.find(params[:id])
    @url = { controller: '/employees', action: :update }
    render :form
  end

  private

  # Sets a proper "Not Found" message.
  def not_found
    super(t('messages.employee.errors.find'))
  end
end
