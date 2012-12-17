# The Contact model provides an interface to store and retrieve contact
# data. It uses the polymorphic association _contactable_ and stores the
# data serialized as JSON.
#
# Every field described in the FIELDS list is accessible through
# a method with the same name and returns a list.
#
# Example:
#
#   class User < ActiveRecord::Base
#     has_one :contact, as: contactable, autosave: true
#   end
#
#   user = User.find(1)
#   user.contact.emails
#   #=> ['mail@example.com']
#   user.contact.emails << 'mail@server.net'
#   #=> ['mail@example.com', 'mail@server.net']
#   user.save
#
# Database scheme:
#
# - *id* integer
# - *contactable_id* integer
# - *contactable_type* string
# - *contact* text
class Contact < ActiveRecord::Base
  serialize :contacts, JSON

  before_save :remove_blanks

  belongs_to :contactable, polymorphic: true

  after_initialize :init_contacts

  # List of contact fields. See model description above for more info.
  FIELDS = [:emails, :p_phones, :b_phones, :m_phones, :fax, :skypes, :websites]

  # Defines an access method for each field in the FIELDS array.
  FIELDS.each do |method|
    define_method(method) { self.contacts[method.to_s] ||= [] }
  end

  # Returns the specified field. Raises an ArgumentError, if the specified
  # field is not a valid one.
  def field(field)
    f = field.to_sym

    unless FIELDS.include?(f)
      raise ArgumentError, "Argument is not a valid field: #{field}"
    end

    send(f)
  end

  # Returns true, if all contact fields are empty, else false.
  def empty?
    FIELDS.all? { |f| send(f).empty? }
  end

  private

  # Initializes the contacts hash.
  def init_contacts
    self.contacts ||= {}
  end

  # Removes all blank values from the contact hash.
  def remove_blanks
    FIELDS.each { |f| send(f).delete_if { |val| val.blank? } }
  end
end
