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
                  :former_collaboration, :country_id, :comment_attributes

  attr_accessible :degree, :prename, :name, :gender, :birthday, :fee, :job,
                  :former_collaboration, :country, as: :exposable

  symbolize :gender, in: [:female, :male]

  validates :name, presence: true

  has_and_belongs_to_many :languages, uniq: true

  has_many :attachments, autosave: true, dependent: :destroy, as: :attachable
  has_many :addresses,   autosave: true, dependent: :destroy, as: :addressable
  has_many :list_items,  autosave: true, dependent: :destroy, as: :item
  has_many :lists,       through:  :list_items

  has_many :cvs, autosave: true, dependent: :destroy,
           select: [:id, :expert_id, :language_id], order: :language_id

  has_one :contact, autosave: true, dependent: :destroy, as: :contactable
  has_one :comment, autosave: true, dependent: :destroy, as: :commentable

  belongs_to :user, select: [:id, :name, :prename]
  belongs_to :country

  accepts_nested_attributes_for :comment

  scope :with_meta, includes(:country, :attachments, :cvs)

  # A little workaround, while waiting for ActiveRecord::NullRelation.
  scope :none, where('1 < 0')

  # Searches for experts. Takes a hash with condtions:
  #
  # - *:name* A (partial) name used to search _name_ and _prename_
  # - *:countries* An array of country ids
  # - *:languages* An array of language ids
  # - *:q* A arbitrary string used for a fulltext search in the _comment_ and
  #   the _cv_
  #
  # The results are ordered by name. If _:q_ is present, the results are
  # ordered by relevance.
  def self.search(params)
    s = self

    unless params[:name].blank?
      s = s.where('name LIKE :n OR prename LIKE :n', n: "%#{params[:name]}%")
    end

    if (countries = params[:countries]).is_a?(Array) && ! countries.empty?
      s = s.where(country_id: countries)
    end

    if (languages = params[:languages]).is_a?(Array) && ! languages.empty?
      return none if (ids = search_languages(languages)).empty?
      s = s.where(id: ids)
    end

    if params[:q].blank?
      return s.order(:name)
    end

    if (ids = search_fulltext(params[:q])).empty?
      return none
    end

    s.where(id: ids).order('FIELD(experts.id, %s)' % ids.join(', '))
  end

  # Searches for experts speaking all of the specified languages.
  #
  #   Expert.search_languages([3, 45, 7, 22])
  #   #=> [4, 6]
  #
  # Returns an unordered array of expert ids.
  def self.search_languages(language_ids)
    sql = <<-SQL
      SELECT experts_languages.expert_id, COUNT(*) AS num
      FROM experts_languages
      WHERE experts_languages.language_id IN (:ids)
      GROUP BY experts_languages.expert_id
      HAVING num >= :num
    SQL

    connection.select_rows(sanitize_sql(
      [sql, ids: language_ids, num: language_ids.size]
    )).map(&:first)
  end

  # Searches the fulltext associations, such as Comment and CV.
  #
  #  Expert.search_fulltext('hello')
  #  #=> [5, 23, 34, 1, 4]
  #
  # Returns an array of expert ids ordered by relevance.
  def self.search_fulltext(query)
    sql = <<-SQL
      (
        SELECT comments.commentable_id AS expert_id,
          MATCH (comments.comment) AGAINST (:q IN BOOLEAN MODE) AS score
        FROM comments
        WHERE comments.commentable_type = 'Expert'
          AND MATCH (comments.comment) AGAINST (:q IN BOOLEAN MODE)
      ) UNION (
        SELECT cvs.expert_id,
          MATCH (cvs.cv) AGAINST (:q IN BOOLEAN MODE) AS score
        FROM cvs
        WHERE MATCH (cvs.cv) AGAINST (:q IN BOOLEAN MODE)
      )
      ORDER BY score DESC
    SQL

    connection.select_rows(sanitize_sql([sql, q: query])).map(&:first)
  end

  # Initializes the contact on access, if not already initalized.
  def contact
    super || self.contact = Contact.new
  end

  # Initializes the comment on access, if not already initialized.
  def comment
    super || self.comment = Comment.new
  end

  # Sets the experts country.
  def country=(country)
    super(Country.find_country(country))
  end

  # Sets the experts languages. So we can do things like:
  #
  #   en = Language.find_by_language('en')
  #   expert.languages = [1, 2, "34", en]
  def languages=(ids)
    super(Language.where(id: ids)) if [Fixnum, Array].include?(ids.class)
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
