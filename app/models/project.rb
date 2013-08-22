#
#
#
class Project < ActiveRecord::Base
  attr_accessible :country_id, :status, :carried_proportion, :start, :end,
                  :partners, :staff_months, :order_value_us, :order_value_eur

  discrete_values :status, [:forecast, :interested, :offer, :execution, :stopped, :complete]

  has_many :info,    auto_save: true, dependent: :destroy, class_name: :ProjectInfo
  has_many :members, auto_save: true, dependent: :destroy, class_name: :ProjectMember
end
