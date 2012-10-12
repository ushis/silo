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

  has_many :employees, autosave: true, dependent: :destroy

  has_one :comment, autosave: true, dependent: :destroy, as: :commentable

  belongs_to :user
  belongs_to :country

  accepts_nested_attributes_for :comment

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
