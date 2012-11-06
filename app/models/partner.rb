# The Partner model provides the ability to manage partner companies.
#
# Database schema:
#
# - *id:*          integer
# - *user_id:*     integer
# - *country_id:*  integer
# - *company:*     string
# - *street:*      string
# - *city:*        string
# - *zip:*         string
# - *region:*      string
# - *website:*     string
# - *email:*       string
# - *phone:*       string
# - *created_at:*  datetime
# - *updated_at:*  datetime
#
# The company attribute is required.
class Partner < ActiveRecord::Base
  attr_accessible :country_id, :company, :street, :city, :zip, :region,
                  :website, :email, :phone,
                  :comment_attributes, :description_attributes

  is_taggable_with :businesses, :advisers

  validates :company, presence: true

  has_and_belongs_to_many :lists,      uniq: true

  has_many :employees,   autosave: true, dependent: :destroy
  has_many :attachments, autosave: true, dependent: :destroy, as: :attachable

  has_one :description, autosave: true, dependent: :destroy
  has_one :comment,     autosave: true, dependent: :destroy, as: :commentable

  belongs_to :user
  belongs_to :country

  accepts_nested_attributes_for :description
  accepts_nested_attributes_for :comment

  scope :with_meta, includes(:country, :attachments)

  # A little workaround, while waiting for ActiveRecord::NullRelation.
  scope :none, where('1 < 0')

  # Searches for partners. Takes a hash of conditions.
  #
  # - *:company* A (partial) company name.
  # - *:countries* An Array of country ids.
  # - *:businesses* An Array of business ids.
  # - *:q* A string used for fulltext search.
  #
  # The results are ordered by company. If _:q_ is present, the results are
  # ordered by relevance.
  def self.search(params)
    s = self

    unless params[:company].blank?
      s = s.where('company LIKE ?', "%#{params[:company]}%")
    end

    if (countries = params[:countries]).is_a?(Array) && ! countries.empty?
      s = s.where(country_id: countries)
    end

    if (businesses = params[:businesses]).is_a?(Array) && ! businesses.empty?
      return none if (ids = search_businesses(businesses)).empty?
      s = s.where(id: ids)
    end

    if params[:q].blank?
      return s.order(:company)
    end

    if (ids = search_fulltext(params[:q])).empty?
      return none
    end

    s.where(id: ids).order('FIELD(partners.id, %s)' % ids.join(', '))
  end

  # Searches the fulltext associations, such as Comment and Description.
  #
  #   Partner.search_fulltext('Banana Split')
  #   #=> [4, 34, 1, 23]
  #
  # Returns an array of partner ids ordered by relevance.
  def self.search_fulltext(query)
    sql = <<-SQL
      (
        SELECT comments.commentable_id AS partner_id,
          MATCH (comments.comment) AGAINST (:q IN BOOLEAN MODE) AS score
        FROM comments
        WHERE comments.commentable_type = 'Partner'
          AND MATCH (comments.comment) AGAINST (:q IN BOOLEAN MODE)
      ) UNION (
        SELECT descriptions.partner_id,
          MATCH (descriptions.description) AGAINST (:q IN BOOLEAN MODE) AS score
        FROM descriptions
        WHERE MATCH (descriptions.description) AGAINST (:q IN BOOLEAN MODE)
      )
      ORDER BY score DESC
    SQL

    connection.select_rows(sanitize_sql([sql, q: query])).map(&:first)
  end

  # Returns the partners description. A new one is initialized if necessary.
  def description
    super || self.description = Description.new
  end

  # Returns the partners comment. A new one is initialized if necessary.
  def comment
    super || self.comment = Comment.new
  end
end
