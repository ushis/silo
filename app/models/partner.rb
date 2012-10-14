# The Partner model provides the ability to manage partner companies.
#
# Database schema:
#
# - *id:*          integer
# - *user_id*      integer
# - *country_id:*  integer
# - *company:*     string
# - *street:*      string
# - *city:*        string
# - *zip:*         string
# - *region:*      string
# - *created_at*   datetime
# - *updated_at*   datetime
#
# The company attribute is required.
class Partner < ActiveRecord::Base
  attr_accessible :country_id, :company, :street, :city, :zip, :region,
                  :businesses, :comment_attributes

  validates :company, presence: true

  has_and_belongs_to_many :businesses, uniq: true
  has_and_belongs_to_many :contact_persons, class_name: :User, uniq: true

  has_many :employees,   autosave: true, dependent: :destroy
  has_many :attachments, autosave: true, dependent: :destroy, as: :attachable

  has_one :comment, autosave: true, dependent: :destroy, as: :commentable

  belongs_to :user
  belongs_to :country

  accepts_nested_attributes_for :comment

  scope :with_meta, includes(:businesses, :attachments)

  scope :none, where('1 < 0')

  default_scope includes(:country)

  def self.search(params)
    s = self

    unless params[:company].blank?
      s = s.where('company LIKE :c', c: "%#{params[:company]}%")
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

  def self.search_businesses(business_ids)
    sql = <<-SQL
      SELECT businesses_partners.partner_id, COUNT(*) AS num
      FROM businesses_partners
      WHERE businesses_partners.business_id IN (:ids)
      GROUP BY businesses_partners.partner_id
      HAVING num >= :num
    SQL

    connection.select_rows(sanitize_sql(
      [sql, ids: business_ids, num: business_ids.size]
    )).map(&:first)
  end

  # Searches the fulltext associations, such as Comment.
  #
  #   Partner.search_fulltext('Banana Split')
  #   #=> [4, 34, 1, 23]
  #
  # Returns an array of partner ids ordered by relevance.
  def self.search_fulltext(query)
    sql = <<-SQL
      SELECT comments.commentable_id
      FROM comments
      WHERE comments.commentable_type = 'Partner'
        AND MATCH (comments.comment) AGAINST (:q IN BOOLEAN MODE)
      ORDER BY MATCH (comments.comment) AGAINST (:q IN BOOLEAN MODE) DESC
    SQL

    connection.select_rows(sanitize_sql([sql, q: query])).map(&:first)
  end

  # Returns the partners comment. A new one is initialized if necessary.
  def comment
    super || self.comment = Comment.new
  end

  # Sets the partners contact persons. Takes an Array of user ids and/or User
  # objects.
  #
  #   partner.contact_persons = ["2", 4, User.first]
  #   #=> ["2", 4, #<User id: 1>]
  #
  #   partner.contact_persons
  #   #=> [#<User id: 2>, #<User id: 4>, #<User id: 1>]
  #
  # Non existing ids where ignored.
  def contact_persons=(users)
    super(User.where(id: users)) if [Fixnum, Array].include?(users.class)
  end

  # Sets the partners businesses. Takes a string of comma separated businesses
  # or a collection of Business objects. See Business.from_s for more details.
  def businesses=(businesses)
    super(businesses.is_a?(String) ? Business.from_s(businesses) : businesses)
  end
end
