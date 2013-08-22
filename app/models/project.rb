#
#
#
class Project < ActiveRecord::Base
  attr_accessible :country_id, :status, :carried_proportion, :start, :end,
                  :partners, :staff_months, :order_value_us, :order_value_eur

  discrete_values :status, [:forecast, :interested, :offer, :execution, :stopped, :complete]

  has_many :infos,   autosave: true, dependent: :destroy, class_name: :ProjectInfo
  has_many :members, autosave: true, dependent: :destroy, class_name: :ProjectMember

  belongs_to :user, select: [:id, :name, :prename]
end
