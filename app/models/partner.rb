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

  self.per_page = 50

  is_taggable_with :advisers
  is_taggable_with :businesses

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

  # Searches for partners. Takes a hash of conditions.
  #
  # - *:company* A (partial) company name.
  # - *:country* On or more country ids.
  # - *:advisers* An Array of adviser ids.
  # - *:businesses* An Array of business ids.
  # - *:q* A string used for fulltext search.
  #
  # The results are ordered by company.
  def self.search(params)
    PartnerSearcher.new(
      params.slice(:company, :country, :advisers, :businesses, :q)
    ).search(scoped).order(:company)
  end

  # Returns the company name.
  def to_s
    company
  end
end
