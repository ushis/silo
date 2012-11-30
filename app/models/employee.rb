# The Employee model provides the possibility to add contact persons to a
# partner company.
#
# Database schema:
#
# - *id:*          integer
# - *partner_id:*  integer
# - *name:*        string
# - *prename:*     string
# - *title:*       string
# - *gender:*      string
# - *job:*         string
# - *created_at:*  datetime
# - *updated_at:*  datetime
#
# Every employee has one Contact.
class Employee < ActiveRecord::Base
  attr_accessible :title, :name, :prename, :gender, :job
  attr_accessible :title, :name, :prename, :gender, :job, as: :exposable

  symbolize :gender, in: [:female, :male], allow_nil: true

  validates :name, presence: true

  has_one :contact, autosave: true, dependent: :destroy, as: :contactable

  belongs_to :partner

  # Returns the employees Contact and initializes one if necessary.
  def contact
    super || self.contact = Contact.new
  end

  # Returns a string containing first name and last name.
  def full_name
    "#{prename} #{name}"
  end

  # Returns a string containing first name, last name and title. Returns
  # Employee#full_name() if the title attribute is blank.
  def full_name_with_title
    title.blank? ? full_name : "#{title} #{full_name}"
  end
end
