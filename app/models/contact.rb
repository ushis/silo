# The Contact model provides an interface to store and retrieve contact
# data. It uses the polymorphic association _contactable_ and stores the
# data serialized as JSON.
#
# Every field described in the _FIELDS_ list is accessible through
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
# The fields list can be retrieved through the method _Contact.fields_.
class Contact < ActiveRecord::Base
  serialize :contacts, JSON

  belongs_to :contactable, polymorphic: true

  after_initialize :init_contacts

  # List of contact fields. See model description above for more info.
  FIELDS = [:emails, :phones, :faxes, :websites]

  FIELDS.each do |method|
    define_method(method) { self.contacts[method.to_s] ||= [] }
  end

  # Returns the fields list.
  def self.fields
    FIELDS
  end

  # Initializes the contacts hash.
  def init_contacts
    self.contacts ||= {}
  end
end
