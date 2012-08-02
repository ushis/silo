#
#
class Address < ActiveRecord::Base
  attr_accessible :street, :zipcode, :city, :country, :more

  belongs_to :addressable, polymorphic: true
end
