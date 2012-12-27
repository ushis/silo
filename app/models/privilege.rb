# The Privilege model is used to hold User permissions.
#
# Database Scheme:
#
# - *user_id* integer
# - *amdin* boolean
# - *experts* boolean
# - *partners* boolean
# - *references* boolean
#
# This is not very fancy.
class Privilege < ActiveRecord::Base
  belongs_to :user

  attr_accessible :admin, :experts, :partners, :references, as: :admin

  # A list of all sections.
  SECTIONS = [:experts, :partners, :references]

  # Checks for access privileges for a specified section.
  #
  #   if privilege.access?(:experts)
  #     write_some_experts_data(data)
  #   end
  #
  # Returns true if access is granted, else false.
  def access?(section)
    admin? || (respond_to?(section) && send(section))
  end

  # Checks permissions to write some employees data. Employee is a subresource
  # of Partner, so the user needs the permissions to write partners data.
  def employees
    partners?
  end
end
