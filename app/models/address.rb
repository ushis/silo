require 'carmen'

# The Address model provides the ability to store addresses and connect
# the to other models through the polymorphic association _addressable_.
#
# Database scheme:
#
# - *id* integer
# - *addressable_id* integer
# - *addressable_type* string
# - *address* text
# - *country* string
class Address < ActiveRecord::Base
  attr_accessible :address, :country

  validates :address, presence: true

  belongs_to :addressable, polymorphic: true

  # Returns a human readable country name.
  def human_country
    Carmen::Country.coded(country).try(:name)
  end
end
