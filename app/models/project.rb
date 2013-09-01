# Handles project related data.
#
# Database schema:
#
# - *id:*                  integer
# - *user_id:*             integer
# - *country_id:*          integer
# - *status:*              string
# - *carried_proportion:*  integer
# - *start*                string
# - *end*                  string
# - *staff_months:*        integer
# - *order_value_us:*      integer
# - *order_value_eur:*     integer
# - *created_at:*          datetime
# - *updated_at:*          datetime
#
# The columns *user_id* and *status* are required.
class Project < ActiveRecord::Base
  attr_accessible :country_id, :status, :carried_proportion, :start, :end,
                  :staff_months, :order_value_us, :order_value_eur

  discrete_values :status, [:forecast, :interested, :offer, :execution, :stopped, :complete]

  validates :carried_proportion, inclusion: 0..100

  has_and_belongs_to_many :partners, uniq: true

  has_many :infos,       autosave: true, dependent: :destroy, class_name: :ProjectInfo,   inverse_of: :project
  has_many :members,     autosave: true, dependent: :destroy, class_name: :ProjectMember, inverse_of: :project
  has_many :attachments, autosave: true, dependent: :destroy, as: :attachable
  has_many :list_items,  autosave: true, dependent: :destroy, as: :item
  has_many :lists,       through:  :list_items

  belongs_to :user, select: [:id, :name, :prename]
  belongs_to :country

  # Orders the projects by title.
  def self.ordered
    includes(:infos).order('project_infos.language, project_infos.title')
  end

  # Returns true if the project has some infos, else false
  def info?
    ! infos.empty?
  end

  # Returns the first info.
  def info
    infos.first
  end

  # Returns an info by given language. Allocates a fresh ProjectInfo, if it
  # doesn't exist.
  def info_by_language(lang)
    infos.find_by_language(lang) || ProjectInfo.new.tap do |info|
      info.project = self
      info.language = lang
    end
  end

  # Returns an info by given language. Raises ActiveRecord::RecordNotFound, if
  # it doesn't esxist.
  def info_by_language!(lang)
    infos.find_by_language!(lang)
  end

  #
  def add_partner(partner)
    partners << partner
  rescue ActiveRecord::RecordNotUnique
    false
  end

  # Returns the first info as a string.
  def to_s
    info.try(:to_s)
  end
end
