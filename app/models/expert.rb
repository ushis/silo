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
  attr_accessible :name, :prename, :gender, :birthday, :fee, :job, :degree,
                  :former_collaboration, :country_id, :languages

  attr_accessible :degree, :prename, :name, :gender, :birthday, :fee, :job,
                  :former_collaboration, :country, as: :exposable

  self.per_page = 50

  symbolize :gender, in: [:female, :male]

  is_commentable_with :comment, autosave: true, dependent: :destroy, as: :commentable

  validates :name, presence: true

  has_and_belongs_to_many :languages, uniq: true

  has_many :attachments, autosave: true, dependent: :destroy, as: :attachable
  has_many :addresses,   autosave: true, dependent: :destroy, as: :addressable
  has_many :list_items,  autosave: true, dependent: :destroy, as: :item
  has_many :lists,       through:  :list_items

  has_many :cvs, autosave: true, dependent: :destroy,
           select: [:id, :expert_id, :language_id], order: :language_id

  has_one :contact, autosave: true, dependent: :destroy, as: :contactable

  belongs_to :user, select: [:id, :name, :prename]
  belongs_to :country

  scope :with_meta, includes(:country, :attachments, :cvs)

  # Searches for experts. Takes a hash with condtions:
  #
  # - *:name* A (partial) name used to search _name_ and _prename_
  # - *:country* One or more country ids
  # - *:languages* An array of language ids
  # - *:q* A arbitrary string used for a fulltext search in the _comment_ and
  #   the _cv_
  #
  # The results are ordered by name and prename.
  def self.search(params)
    ExpertSearcher.new(
      params.slice(:name, :country, :languages, :q)
    ).search(scoped).order('name, prename')
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

  # Adds an uploaded Cv to the expert.
  #
  #   expert.add_cv_from_upload(params[:cv])
  #   #=> [#<Cv id: 1323, expert_id: 12>, #<Cv id: 1684, expert_id: 12>]
  #
  # Returns the experts Cvs or false on error.
  def add_cv_from_upload(data)
    begin
      cv = Cv.from_file(data[:file], data[:language_id])
    rescue
      return false
    end

    unless (self.cvs << cv)
      cv.destroy
      return false
    end

    cvs
  end

  # Returns a string containing name and prename.
  def full_name
    "#{prename} #{name}"
  end

  alias :to_s :full_name

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

  # Returns the experts age or nil if the birthday is unknown.
  #
  #   expert.age
  #   #=> 43
  def age
    return nil unless birthday

    now = Time.now.utc.to_date
    age = now.year - birthday.year

    (now.month < birthday.month ||
      (now.month == birthday.month && now.day < birthday.day)) ? age - 1 : age
  end
end
