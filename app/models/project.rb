# Handles project related data.
#
# Database schema:
#
# - *id:*                  integer
# - *user_id:*             integer
# - *country_id:*          integer
# - *status:*              string
# - *carried_proportion:*  integer
# - *start*                date
# - *end*                  date
# - *order_value_us:*      integer
# - *order_value_eur:*     integer
# - *created_at:*          datetime
# - *updated_at:*          datetime
#
# The columns *user_id* and *status* are required.
class Project < ActiveRecord::Base
  attr_accessible :country_id, :status, :carried_proportion, :start, :end,
                  :order_value_us, :order_value_eur

  discrete_values :status, [:forecast, :interested, :offer, :execution, :stopped, :complete]

  validates :carried_proportion, inclusion: 0..100
  validate  :start_must_be_earlier_than_end

  DEFAULT_ORDER = 'projects.title'

  has_and_belongs_to_many :partners, uniq: true

  has_many :infos,       autosave: true, dependent: :destroy, class_name: :ProjectInfo,   inverse_of: :project
  has_many :members,     autosave: true, dependent: :destroy, class_name: :ProjectMember, inverse_of: :project
  has_many :attachments, autosave: true, dependent: :destroy, as: :attachable
  has_many :list_items,  autosave: true, dependent: :destroy, as: :item
  has_many :lists,       through:  :list_items

  belongs_to :user, select: [:id, :name, :prename]
  belongs_to :country

  # Searches for projects. Takes a hash of conditions.
  #
  # - *:title*   a (partial) title
  # - *:status*  a projects status
  # - *:start*   year before the projects start
  # - *:end*     year after the projects end
  # - *:q*       string used for fulltext search
  #
  # The results are ordered by title.
  def self.search(params)
    ProjectSearcher.new(
      params.slice(:title, :status, :start, :end, :q)
    ).search(scoped).ordered
  end

  # Orders the projects by title.
  def self.ordered
    order(DEFAULT_ORDER)
  end

  # Returns the first year of the max possible period.
  def self.first_period_year
    1970
  end

  # Returns the last year of the max possible period.
  def self.last_period_year
    Time.now.year + 50
  end

  # Returns the max possible period.
  def self.max_period
    first_period_year..last_period_year
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

  # Returns a collection of potential partners.
  def potential_partners(q)
    Partner.where('id NOT IN (:ids) AND company LIKE :q', ids: partners.pluck(:id), q: "%#{q}%")
  end

  # Adds a partners to the project.
  def add_partner(partner)
    partners << partner
  rescue ActiveRecord::RecordNotUnique
    false
  end

  # Updates the title.
  def update_title
    update_attribute(:title, info.try(:title))
  end

  # Returns the first info as a string.
  def to_s
    title.to_s
  end

  private

  def start_must_be_earlier_than_end
    if ! self.start.nil? && ! self.end.nil? && self.start > self.end
      errors.add(:start, I18n.t('messages.errors.project.start_later_than_end'))
      errors.add(:end, I18n.t('messages.errors.project.start_later_than_end'))
    end
  end
end
