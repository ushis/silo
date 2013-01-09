require 'set'

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
  FIELDS = %w(emails p_phones b_phones m_phones fax skypes websites).to_set

  # Defines an access method for each field in the FIELDS array.
  FIELDS.each do |method|
    define_method(method) { self.contacts[method] ||= [] }
  end

  # Adds a contact to a field. Checks for valid fields, values and duplicates.
  #
  #   contact.add(:emails, 'jane@doe.com')
  #   #=> ['jane@doe.com', 'jane@aol.com']
  #
  # Returns the field or false on error.
  def add(field, value)
    field, value = normalize_input(field, value)

    if value.present? && FIELDS.include?(field) && ! send(field).include?(value)
      send(field) << value
    else
      false
    end
  end

  # Does the same as Contact#add, but saves the record.
  #
  # Returns true on success, else false.
  def add!(field, value)
    add(field, value) && save
  end

  # Removes a contact from a field. Checks the validity of field.
  #
  #   contact.remove(:emails, 'jane@doe.com')
  #   #=> 'jane@doe.com'
  #
  # Returns the removed contact, or something falsy on error.
  def remove(field, value)
    field, value = normalize_input(field, value)

    FIELDS.include?(field) && send(field).delete(value)
  end

  # Does the same as Contact#remove, but saves the record.
  #
  # Returns true on success, else false.
  def remove!(field, value)
    remove(field, value) && save
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
    FIELDS.each { |f| send(f).delete_if(&:blank?) }
  end

  # Normalizes untrusted input values.
  def normalize_input(field, value)
    [ field.to_s.downcase.strip, value.to_s.strip ]
  end
end
