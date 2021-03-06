# The Expert model provides access to the experts data and several methods
# for manipulation.
#
# Database scheme:
#
# - *id:*                    integer
# - *user_id:*               integer
# - *country_id:*            integer
# - *name:*                  string
# - *prename:*               string
# - *gender:*                string
# - *birthday:*              date
# - *degree:*                string
# - *former_collaboration:*  boolean
# - *fee:*                   string
# - *job:*                   string
# - *created_at:*            datetime
# - *updated_at:*            datetime
class Expert < ActiveRecord::Base
  attr_accessible :name, :prename, :degree, :gender, :birthday, :fee, :job,
                  :former_collaboration, :country_id, :languages

  attr_exposable :name, :prename, :degree, :gender, :birthday, :fee, :job,
                 :former_collaboration, :country, as: :csv

  attr_exposable :name, :prename, :degree, :gender, :age, :fee, :job,
                 :former_collaboration, :country, as: :pdf

  self.per_page = 50

  DEFAULT_ORDER = 'experts.name, experts.prename'

  discrete_values :gender, [:male, :female]

  is_commentable_with :comment, autosave: true, dependent: :destroy, as: :commentable

  validates :name, presence: true

  has_and_belongs_to_many :languages, uniq: true

  has_many :attachments,     autosave: true, dependent: :destroy, as: :attachable
  has_many :addresses,       autosave: true, dependent: :destroy, as: :addressable
  has_many :list_items,      autosave: true, dependent: :destroy, as: :item
  has_many :lists,           through:  :list_items
  has_many :project_members, autosave: true, dependent: :destroy
  has_many :projects,        through:  :project_members

  has_many :cvs, autosave: true, dependent: :destroy,
           select: [:id, :expert_id, :language_id], order: :language_id

  has_one :contact, autosave: true, dependent: :destroy, as: :contactable

  belongs_to :user, select: [:id, :name, :prename]
  belongs_to :country

  scope :with_meta, includes(:country, :attachments, :cvs)

  # Searches for experts. Takes a hash with condtions:
  #
  # - *:name*       a (partial) name used to search _name_ and _prename_
  # - *:country*    one or more country ids
  # - *:languages*  an array of language ids
  # - *:q*          arbitrary string used for a fulltext search
  #
  # The results are ordered by name and prename.
  def self.search(params)
    ExpertSearcher.new(
      params.slice(:name, :country, :languages, :q)
    ).search(scoped).ordered
  end

  # Returns a collection of ordered experts.
  def self.ordered
    order(DEFAULT_ORDER)
  end

  # Initializes the contact on access, if not already initalized.
  def contact
    super || self.contact = Contact.new
  end

  # Sets the experts country.
  def country=(country)
    super(Country.find_country(country))
  end

  # Sets the experts languages.
  #
  # See Language.find_languages for more info.
  def languages=(ids)
    super(Language.find_languages(ids))
  end

  # Returns a string containing name and prename.
  def full_name
    "#{prename} #{name}"
  end

  # Returns a string containing degree, prename and name.
  #
  #   expert.full_name_with_degree
  #   #=> "Alan Turing, Ph.D."
  #
  # If degree is blank, Expert#full_name is returned.
  def full_name_with_degree
    degree.blank? ? full_name : "#{full_name}, #{degree}"
  end

  # Returns the localized former collaboration value.
  def human_former_collaboration
    I18n.t(former_collaboration.to_s, scope: [:values, :boolean])
  end

  # Returns the localized date of birth.
  #
  #   expert.human_birthday
  #   #=> "12. September 2012"
  #
  # Returns nil, if birthday is nil.
  def human_birthday(format = :short)
    I18n.l(birthday, format: format) if birthday
  end

  # Returns the experts age in years.
  #
  #   expert.age  #=> 43
  #
  # Returns nil if the birthday is unknown.
  def age
    return nil unless birthday

    now = Time.now.utc.to_date
    age = now.year - birthday.year

    (now.month < birthday.month ||
      (now.month == birthday.month && now.day < birthday.day)) ? age - 1 : age
  end

  # Returns a combination of name and prename.
  def to_s
    [name, prename].reject(&:blank?).join(', ')
  end
end
