require 'carmen'

# The Address model
#
# Database scheme:
#
# - *id* integer
# - *addressable_id* integer
# - *addressable_type* string
# - *street* string
# - *zipcode* string
# - *city* string
# - *country* string
# - *more* string
class Address < ActiveRecord::Base
  attr_accessible :street, :zipcode, :city, :country, :more

  belongs_to :addressable, polymorphic: true

  # Returns a human readable country name.
  def human_country
    Carmen::Country.coded(country).try(:name)
  end
end
