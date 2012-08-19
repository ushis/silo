# The Address model provides the ability to store addresses and connect
# the to other models through the polymorphic association _addressable_.
#
# Database scheme:
#
# - *id* integer
# - *addressable_id* integer
# - *addressable_type* string
# - *country_id* integer
# - *address* text
class Address < ActiveRecord::Base
  attr_accessible :address, :country

  validates :address, presence: true

  belongs_to :addressable, polymorphic: true
  belongs_to :country

  default_scope includes(:country)

  # Sets the country from an id.
  def country=(country)
    super(Country.find_country(country))
  end
end
