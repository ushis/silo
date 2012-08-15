require 'set'
require 'carmen'
require 'eu'

# The Expert model provides access to the experts data and several methods
# for manipulation.
#
# Database scheme:
#
# - *id* integer
# - *user_id* integer
# - *name* string
# - *prename* string
# - *gender* string
# - *birthday* date
# - *citizenship* string
# - *degree* string
# - *former_collaboration* boolean
# - *fee* string
# - *job* string
# - *created_at* datetime
# - *updated_at* datetime
class Expert < ActiveRecord::Base
  attr_accessible(:name, :prename, :gender, :birthday, :fee, :job,
                  :citizenship, :degree, :former_collaboration)

  has_one    :contact,     autosave: true, dependent: :destroy, as: :contactable
  has_one    :comment,     autosave: true, dependent: :destroy, as: :commentable
  has_many   :attachments, autosave: true, dependent: :destroy, as: :attachable
  has_many   :addresses,   autosave: true, dependent: :destroy, as: :addressable
  has_many   :langs,       autosave: true, dependent: :destroy, as: :langable
  has_many   :cvs,         autosave: true, dependent: :destroy
  has_many   :languages,   through: :langs
  belongs_to :user

  # Set of vailable genders.
  GENDERS = [:female, :male].to_set

  # Returns a valid gender symbol using the GENDERS list.
  #
  #   Expert.gender('female')
  #   #=> :female
  #
  # If no valid symbol is found, the first symbol in GENDERS is returned.
  def self.gender(gender)
    g = gender.try(:to_sym)
    GENDERS.include?(g) ? g : GENDERS.first
  end

  # Searches for experts. Takes a hash with condtions:
  #
  # - *:name* A (partial) name used to search _name_ and _prename_
  # - *:citizenship* A valid country code
  # - *:degree* A valid _degree_
  # - *:language* A valid _language_id_
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

    [:citizenship, :degree].each do |field|
      unless params[field].blank?
        s = s.where(field => params[field])
      end
    end

    unless (language = params[:language]).blank?
      s = s.includes(:languages).where('languages.id = ?', language)
    end

    if ! params[:q].blank? && ! (ids = search_fulltext(params[:q])).empty?
      return s.where(id: ids).order('FIELD(experts.id, %s)' % ids.join(', '))
    end

    s.order(:name)
  end

  # Searches the culltext associations, such as Comment and CV.
  #
  #  Expert.search_fulltext('hello')
  #  #=> [5, 23, 34, 1, 4]
  #
  # Returns an array of expert ids ordered by relevance.
  def self.search_fulltext(query)
    sql = <<-SQL
      ( SELECT comments.commentable_id AS expert_id,
          MATCH (comments.comment) AGAINST (:q) AS score
        FROM comments
        WHERE comments.commentable_type = 'Expert'
          AND MATCH (comments.comment) AGAINST (:q) )
      UNION
      ( SELECT cvs.expert_id, MATCH (cvs.cv) AGAINST (:q) AS score
        FROM cvs
        WHERE MATCH (cvs.cv) AGAINST (:q) )
      ORDER BY score DESC
    SQL

    connection.select_all(sanitize_sql([sql, q: query])).collect do |i|
      i['expert_id']
    end
  end

  # Initializes the contact on access, if not already initalized.
  def contact
    super || self.contact = Contact.new
  end

  # Initializes the comment on access, if not already initialized.
  def comment
    super || self.comment = Comment.new
  end

  # Returns the experts gender.
  def gender
    Expert.gender(super)
  end

  # Sets the experts gender. If the given gender is invalid, a default value
  # is assigned.
  def gender=(gender)
    super(Expert.gender(gender))
  end

  # Sets the experts languages. So we can do things like:
  #
  #   en = Language.find_by_language('en')
  #   expert.languages = [1, 2, "34", en]
  def languages=(ids)
    super(Language.where(id: ids)) if [Fixnum, Array].include?(ids.class)
  end

  # Returns true if expert is an EU citizen, else false.
  def eu?
    Eu.eu?(citizenship)
  end

  # Returns the localized country name.
  def human_citizenship
    Carmen::Country.coded(citizenship).try(:name)
  end

  # Returns a string containing name and prename.
  def full_name
    "#{prename} #{name}"
  end

  # Returns a string containing degree, prename and name.
  #
  #   expert.full_name_with_degree
  #   #=> "Alan Turing, Ph.D."
  def full_name_with_degree
    if degree
      "#{full_name}, #{degree}"
    else
      full_name
    end
  end

  # Returns the experts age or nil if the birthday is unknown.
  #
  #   expert.age
  #   #=> 43
  def age
    return nil unless birthday

    now = Time.now.utc.to_date
    age = now.year - birthday.year

    if now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)
      age - 1
    else
      age
    end
  end
end
