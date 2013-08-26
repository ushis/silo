#
#
#
class Project < ActiveRecord::Base
  attr_accessible :country_id, :status, :carried_proportion, :start, :end,
                  :staff_months, :order_value_us, :order_value_eur

  discrete_values :status, [:forecast, :interested, :offer, :execution, :stopped, :complete]

  has_and_belongs_to_many :partners, uniq: true

  has_many :infos,   autosave: true, dependent: :destroy, class_name: :ProjectInfo,   inverse_of: :project
  has_many :members, autosave: true, dependent: :destroy, class_name: :ProjectMember, inverse_of: :project

  belongs_to :user, select: [:id, :name, :prename]
  belongs_to :country

  # Orders the projects by title.
  def self.ordered
    joins('LEFT JOIN project_infos AS pi ON pi.project_id = projects.id')
      .group('projects.id').order('pi.language, pi.title')
  end

  # Returns true if the project has some infos, else false
  def info?
    ! infos.empty?
  end

  # Returns the first info.
  def info
    infos.first
  end
end
