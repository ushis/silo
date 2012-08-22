# The Country model provides the ability to associate arbitrary models with
# one or more countries.
#
# Database scheme:
#
# - *id* integer
# - *country* string
# - *area* string
class Country < ActiveRecord::Base
  attr_accessible :country, :area

  validates :country, uniqueness: true

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

  # Returns a collection of all countries ordered by localized country name-
  def self.ordered
    Rails.cache.fetch("countries_#{I18n.locale}") do
      all.sort { |x, y| x.human <=> y.human }
    end
  end

  # Returns a list of tuples containing the area name and a list of
  # country tuples ordered by localized country name.
  #
  #   Country.ordered_by_area
  #   #=> [
  #   #     ["Afrika", [["Algeria", 62], ["Angole", 8], ...]],
  #   #     ["Europe", [["Austria", 12], ...]],
  #   #     ...
  #   #   ]
  def self.grouped_by_area
    Rails.cache.fetch("countries_by_area_#{I18n.locale}") do
      map = ActiveSupport::OrderedHash.new

      order(:area).all.each do |country|
        map[country.human_area] ||= []
        map[country.human_area] << [country.human, country.id]
      end

      map.collect do |area, countries|
        [area, countries.sort { |x, y| x[0] <=> y[0] }]
      end
    end
  end

  # Returns the localized country name.
  def human
    I18n.t(country, scope: :countries)
  end

  # Returns the localized area name.
  def human_area
    I18n.t(area, scope: :areas)
  end
end
