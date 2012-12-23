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

  has_many :addresses
  has_many :experts
  has_many :partners

  belongs_to :area

  # Polymorphic method to find a country.
  #
  #   Country.find_country("GB")
  #   #=> #<Country id: 77, country: "GB", area: "E2">
  #
  # Returns nil, when  no country is found.
  def self.find_country(country)
    country.is_a?(self) ? country : find_countries(country).first
  end

  # Finds countries by id or country code.
  #
  # Returns a ActiveRecord::Relation.
  def self.find_countries(query)
    where('countries.id IN (:q) OR countries.country IN (:q)', q: query)
  end

  # Returns the localized country name.
  def human
    I18n.t(country, scope: :countries)
  end

  alias :to_s :human
end
