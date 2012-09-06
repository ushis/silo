# The Country model provides the ability to associate arbitrary models with
# one or more countries.
#
# Database scheme:
#
# - *id* integer
# - *area_id* integer
# - *country* string
class Country < ActiveRecord::Base
  attr_accessible :country, :area

  validates :country, presence: true, uniqueness: true

  belongs_to :area

  # Polymorphic method to find a country.
  #
  #   Country.find_country("GB")
  #   #=> #<Country id: 77, country: "GB", area: "E2">
  #
  # Returns nil, if no country is found.
  def self.find_country(country)
    case country
    when Country
      country
    when Fixnum, Array
      find_by_id(country)
    when Symbol
      find_by_country(country)
    when String
      (id = country.to_i) > 0 ? find_by_id(id) : find_by_country(country)
    else
      nil
    end
  end

  # Returns the localized country name.
  def human
    I18n.t(country, scope: :countries)
  end

  alias :to_s :human
end
