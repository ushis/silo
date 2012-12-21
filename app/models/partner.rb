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
# - *fax:*         string
# - *created_at:*  datetime
# - *updated_at:*  datetime
#
# The company attribute is required.
class Partner < ActiveRecord::Base
  attr_accessible :country_id, :company, :street, :city, :zip, :region,
                  :website, :email, :phone, :fax

  attr_accessible :company, :street, :zip, :city, :region, :country, :website,
                  :email, :phone, :fax, as: :exposable

  is_taggable_with :businesses, :advisers

  is_commentable_with :description, autosave: true, dependent: :destroy
  is_commentable_with :comment,     autosave: true, dependent: :destroy, as: :commentable

  validates :company, presence: true

  has_many :employees,   autosave: true, dependent: :destroy
  has_many :attachments, autosave: true, dependent: :destroy, as: :attachable
  has_many :list_items,  autosave: true, dependent: :destroy, as: :item
  has_many :lists,       through:  :list_items

  belongs_to :user
  belongs_to :country

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

    unless params[:q].blank?
      return none if (ids = search_fuzzy(params[:q])).empty?
      s = s.where(id: ids)
    end

    s.order(:company)
  end

  # Searches weaker attributes (such as street, city, ...) and associations.
  #
  #   Partner.search_fuzzy('Banana')
  #   #=> [23, 445, 12, 134]
  #
  # Returns an Array of unordered partner ids.
  def self.search_fuzzy(query)
    sql = <<-SQL
      (
        SELECT partners.id
        FROM partners
        WHERE partners.street LIKE :like
          OR partners.zip LIKE :like
          OR partners.city LIKE :like
          OR partners.region LIKE :like
      ) UNION (
        SELECT employees.partner_id
        FROM employees
        WHERE employees.prename LIKE :like
          OR employees.name LIKE :like
      ) UNION (
        SELECT advisers_partners.partner_id
        FROM advisers_partners
        JOIN advisers
        ON advisers.id = advisers_partners.adviser_id
        WHERE advisers.adviser LIKE :like
      ) UNION (
        SELECT comments.commentable_id
        FROM comments
        WHERE comments.commentable_type = 'Partner'
          AND MATCH (comments.comment) AGAINST (:q)
      ) UNION (
        SELECT descriptions.partner_id
        FROM descriptions
        WHERE MATCH (descriptions.description) AGAINST (:q)
      )
    SQL

    connection.select_rows(sanitize_sql(
      [sql, q: query, like: "%#{query}%"]
    )).map(&:first)
  end

  # Returns the company name.
  def to_s
    company
  end
end
