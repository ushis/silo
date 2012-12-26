# The PartnerReport provides report rendering of the reports for a Partner.
class PartnerReport < ApplicationReport

  # Builds the report.
  def initialize(partner, user)
    super(partner, user)
    info_table
    comment
    employees
  end

  private

  # Lists the employees.
  def employees
    h2 :employees
    @record.employees.empty? ? p('-') : employee_tables
  end

  # Renders the employee tables.
  def employee_tables
    @record.employees.each do |employee|
      h3 employee.full_name
      info_table(employee)
      contacts_table(employee)
    end
  end
end
